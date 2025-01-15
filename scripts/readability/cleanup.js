const fetch = (...args) => import('node-fetch').then(({ default: fetch }) => fetch(...args));
const { JSDOM } = require('jsdom');
const fs = require('fs/promises'); // Use promises for file operations
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

// Function to check if a string is a valid URL
function isValidUrl(string) {
    try {
        new URL(string);
        return true;
    } catch (_) {
        return false; // Not a valid URL
    }
}
async function extractContent(input) {
    try {
        let html;
        let domInstance;

        if (isValidUrl(input)) {
            // Fetch the webpage if input is a valid URL
            const response = await fetch(input);
            html = await response.text();
            domInstance = new JSDOM(html, { url: input });
        } else {
            // Read content from file if input is not a URL
            html = await fs.readFile(input, 'utf-8');
            domInstance = new JSDOM(html);
        }

        // Create DOMPurify instance bound to the window and clean HTML
        const { window } = domInstance;
        const purify = DOMPurify(window);
        const purifiedHtml = purify.sanitize(html, { IN_PLACE: true, WHOLE_DOCUMENT: true });

        // Create a new DOM from cleaned HTML with the original URL if applicable
        const purifiedDom = new JSDOM(purifiedHtml, {
            url: isValidUrl(input) ? input : undefined
        });

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