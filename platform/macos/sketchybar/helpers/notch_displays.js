// Print the DirectDisplayIDs of screens with a camera notch, space-separated.
//   osascript -l JavaScript helpers/notch_displays.js
ObjC.import("AppKit");

function run() {
	const screens = $.NSScreen.screens;
	const ids = [];
	for (let i = 0; i < screens.count; i++) {
		const screen = screens.objectAtIndex(i);
		if (screen.safeAreaInsets.top > 0) {
			ids.push(screen.deviceDescription.objectForKey("NSScreenNumber").js);
		}
	}
	return ids.join(" ");
}
