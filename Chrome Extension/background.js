chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
	chrome.pageAction.show(tabId); 
});
chrome.pageAction.onClicked.addListener(function(tab) {	
	chrome.tabs.update(tab.id, {url: "crossshare://airdrop?url=" + encodeURIComponent(tab.url) });
});