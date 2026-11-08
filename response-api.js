// Only public browser credentials belong here. No database password or service key.
(function () {
  function submissionRequest(config, payload) {
    if (config.collectionEnabled !== true) return null;
    const url = config.supabaseUrl || '';
    if (/^https:\/\/[a-z0-9-]+\.supabase\.co\/?$/.test(url) && config.publishableKey) {
      return {
        url: url.replace(/\/$/, '') + '/rest/v1/rpc/submit_ai_quiz',
        options: {
          method: 'POST',
          headers: { 'Content-Type': 'application/json', apikey: config.publishableKey },
          body: JSON.stringify({ p_payload: payload })
        }
      };
    }
    if (typeof config.apiUrl === 'string' && config.apiUrl.startsWith('https://')) {
      return {
        url: config.apiUrl,
        options: { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) }
      };
    }
    return null;
  }
  window.quizSubmissionRequest = submissionRequest;
})();
