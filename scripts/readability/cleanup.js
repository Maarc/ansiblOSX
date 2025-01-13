const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { JSDOM } = require('jsdom');
const DOMPurify = require('dompurify');
const { Readability } = require('@mozilla/readability');

function sanitizeDOM(document, window) {
    const createDOMPurify = require("dompurify");
    const DOMPurify = createDOMPurify(window);
    DOMPurify.sanitize(document.documentElement, { IN_PLACE: true, WHOLE_DOCUMENT: true });
    return document.documentElement.outerHTML;
}

async function getHTML(document, window) {
    return await sanitizeDOM(document, window);
}

async function extractContent(url) {
    try {
        // Fetch the webpage
        const response = await fetch(url);
        const html = await response.text();
        const dom = new JSDOM(html, { url });
        const window = dom.window;

        // Create DOMPurify instance bound to the window
        const purify = DOMPurify(window);
        // Clean the HTML
        const purifiedHtml = purify.sanitize(html,  {IN_PLACE: true, WHOLE_DOCUMENT: true});
        // Create a new DOM from cleaned HTML
        const purifiedDom = new JSDOM(purifiedHtml, { url });

        // Parse the content with Readability
        const reader = new Readability(purifiedDom.window.document, { debug: false });
        const article = reader.parse();

        if (article) {
            // Title
            console.log(article.title);
            console.log('');
            // Content
            console.log(article.textContent);
        } else {
            cleanHtml = await getHTML(window.document, window);
            // Regular expression to find the content between <title> and </title>
            const titleMatch = cleanHtml.match(/<title>(.*?)<\/title>/i);

            // Extract the title content if it exists
            const title = titleMatch ? titleMatch[1] : null;
            console.log(title); // The title content or null if not found

            console.log('');
            console.log(cleanHtml);
        }
    } catch (error) {
        console.error('Error:', error);
    }
}

// Usage example
const targetUrl = process.argv[2];
if (!targetUrl) {
    console.error('Please provide a URL as a command line argument');
    process.exit(1);
}

extractContent(targetUrl);