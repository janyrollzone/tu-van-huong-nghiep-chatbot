import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const systemInstruction = `Bạn chỉ trả lời bằng tiếng Việt và là tư vấn viên hướng nghiệp cho học sinh THPT Việt Nam. Chỉ trao đổi về hướng nghiệp, ngành học, kỹ năng học tập và lựa chọn trường/nghề; với nội dung khác, từ chối lịch sự và mời người dùng quay lại chủ đề hướng nghiệp.

Trước khi kết luận hoặc gợi ý ngành, hãy lần lượt tìm hiểu sở thích, môn học thế mạnh, tính cách và mong muốn nghề nghiệp. Nếu còn thiếu bất kỳ điểm nào, chỉ đặt câu hỏi ngắn, thân thiện để làm rõ. Khi đã đủ thông tin, gợi ý 2 đến 3 ngành. Mỗi ngành phải có lý do phù hợp, kỹ năng nên phát triển, nghề nghiệp liên quan và tổ hợp xét tuyển tham khảo. Luôn nói rõ tổ hợp xét tuyển có thể thay đổi theo từng trường và từng năm.`;

Deno.serve(async (request) => {
  const origin = request.headers.get('Origin') ?? '';
  const isAllowed = origin == 'https://janyrollzone.github.io' || /^http:\/\/localhost:\d+$/.test(origin);
  const headers = { ...corsHeaders, 'Access-Control-Allow-Origin': isAllowed ? origin : 'https://janyrollzone.github.io' };
  if (request.method === 'OPTIONS') return new Response('ok', { headers });
  if (request.method !== 'POST') return new Response('Method not allowed', { status: 405, headers });

  const authorization = request.headers.get('Authorization');
  if (!authorization) return json({ error: 'Bạn cần đăng nhập để sử dụng chatbot.' }, 401, headers);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authorization } } },
  );
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return json({ error: 'Phiên đăng nhập không hợp lệ. Vui lòng đăng nhập lại.' }, 401, headers);

  const { messages } = await request.json();
  if (!Array.isArray(messages) || messages.length == 0) {
    return json({ error: 'Không có nội dung hội thoại để xử lý.' }, 400, headers);
  }

  const response = await fetch(
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-3-flash-preview:generateContent',
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', 'x-goog-api-key': Deno.env.get('GEMINI_API_KEY') ?? '' },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: systemInstruction }] },
        contents: messages,
      }),
    },
  );
  if (!response.ok) {
    const detail = await response.text();
    console.error('Gemini error', response.status, detail);
    return json({ error: `Gemini từ chối yêu cầu (mã ${response.status}): ${detail.slice(0, 500)}` }, 502, headers);
  }
  const payload = await response.json();
  const text = payload.candidates?.[0]?.content?.parts?.map((part: { text?: string }) => part.text ?? '').join('').trim();
  if (!text) return json({ error: 'Gemini chưa trả về nội dung. Vui lòng thử lại.' }, 502, headers);
  return json({ text }, 200, headers);
});

function json(body: unknown, status: number, cors: Record<string, string>) {
  return new Response(JSON.stringify(body), { status, headers: { ...cors, 'Content-Type': 'application/json' } });
}
