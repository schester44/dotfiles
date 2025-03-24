const workBrowser = { name: "Google Chrome" };

module.exports = {
  defaultBrowser: "Google Chrome",
  options: {
    hideIcon: false,
    checkForUpdate: true,
    logRequests: false,
  },
  handlers: [
    {
      match: ({ url }) => url.host === "reddit.com",
      browser: "Firefox",
    },
    {
      // Open any link clicked in Slack in Chrome
      match: ({ opener }) => opener.bundleId === "com.tinyspeck.slackmacgap",
      browser: workBrowser,
    },
    {
      // Open links in Firefox for any Notes app links
      match: ({ opener }) => opener.bundleId === "com.apple.Notes",
      browser: "Firefox",
    },
    {
      // Open links in Firefox for any Reminders app links
      match: ({ opener }) => opener.bundleId === "com.apple.reminders",
      browser: "Firefox",
    },
    {
      match: ({ url }) => url.host === "meet.google.com",
      browser: workBrowser,
    },
  ],
};
