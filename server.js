const express = require('express');
const axios = require('axios');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

app.post('/tiktok', async (req, res) => {
  try {
    let { url } = req.body;

    if (!url) {
      console.log('⚠️ Missing TikTok URL parameter.');
      return res.status(400).json({ 
        success: false, 
        error: 'Missing TikTok URL parameter' 
      });
    }

    console.log(`📥 Received request for URL: ${url}`);

    // Resolve short links (like vt.tiktok.com) to full URLs
    try {
      const redirectRes = await axios.get(url, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36'
        },
        maxRedirects: 5,
        timeout: 8000
      });
      if (redirectRes.request?.res?.responseUrl) {
        url = redirectRes.request.res.responseUrl;
        console.log(`🔗 Expanded Full URL: ${url}`);
      }
    } catch (e) {
      console.log('ℹ️ Using original URL (Redirect resolution skipped)');
    }

    // Request to TikWM API
    const params = new URLSearchParams();
    params.append('url', url);
    params.append('hd', '1');

    const apiRes = await axios.post('https://www.tikwm.com/api/', params, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
        'Accept': 'application/json, text/javascript, */*; q=0.01',
        'Origin': 'https://www.tikwm.com',
        'Referer': 'https://www.tikwm.com/'
      },
      timeout: 15000
    });

    const responseData = apiRes.data;

    if (!responseData || responseData.code !== 0 || !responseData.data) {
      console.error('❌ TikWM Response Error:', JSON.stringify(responseData));
      return res.status(400).json({
        success: false,
        error: responseData?.msg || 'Failed to fetch video. Verify the link is valid and public.'
      });
    }

    const data = responseData.data;

    const responseBody = {
      success: true,
      title: data.title || 'TikTok Video',
      author: data.author?.nickname || 'Unknown Author',
      videoUrl: data.play || data.wmplay,
      audioUrl: data.music || null,
      thumbnailUrl: data.cover || null,
    };

    console.log(`✅ SUCCESS! Fetched Video: "${responseBody.title}"`);
    return res.status(200).json(responseBody);

  } catch (err) {
    console.error('❌ Internal Server Exception:', err.response?.data || err.message);
    return res.status(500).json({ 
      success: false, 
      error: 'Server Error: ' + (err.message || 'Unable to reach TikTok service') 
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 TikTok Webhook Server running on http://192.168.18.208:${PORT}`);
});