// Custom JavaScript for CKA Exam site
document.addEventListener('DOMContentLoaded', function() {
    // Add copy button to all code blocks
    document.querySelectorAll('pre').forEach(function(preBlock) {
        var button = document.createElement('button');
        button.className = 'copy-button';
        button.textContent = 'Copy';
        button.style.cssText = 'position:absolute;top:10px;right:10px;padding:4px 12px;font-size:12px;';
        
        preBlock.style.position = 'relative';
        preBlock.appendChild(button);
        
        button.addEventListener('click', function() {
            var code = preBlock.querySelector('code');
            navigator.clipboard.writeText(code.textContent).then(function() {
                var originalText = button.textContent;
                button.textContent = 'Copied!';
                button.style.background = '#28a745';
                setTimeout(function() {
                    button.textContent = originalText;
                    button.style.background = '';
                }, 2000);
            });
        });
    });
    
    // Add exam badges to headers
    document.querySelectorAll('h2, h3').forEach(function(header) {
        var text = header.textContent.toLowerCase();
        
        if (text.includes('question') || text.includes('q)')) {
            var badge = document.createElement('span');
            badge.className = 'exam-badge';
            badge.textContent = 'QUESTION';
            badge.style.background = '#dc3545';
            header.appendChild(badge);
        }
        
        if (text.includes('exam') || text.includes('practice')) {
            var badge = document.createElement('span');
            badge.className = 'exam-badge';
            badge.textContent = 'PRACTICE';
            badge.style.background = '#ffc107';
            badge.style.color = '#000';
            header.appendChild(badge);
        }
        
        if (text.includes('important') || text.includes('key')) {
            var badge = document.createElement('span');
            badge.className = 'exam-badge';
            badge.textContent = 'IMPORTANT';
            badge.style.background = '#326ce5';
            header.appendChild(badge);
        }
    });
    
    // Add Kubernetes theme to all kubectl commands
    document.querySelectorAll('code').forEach(function(code) {
        if (code.textContent.includes('kubectl') || 
            code.textContent.includes('docker') ||
            code.textContent.includes('helm')) {
            code.style.fontWeight = 'bold';
            code.style.color = '#326ce5';
        }
    });
    
    // Add last updated timestamp
    var lastUpdated = document.createElement('div');
    lastUpdated.style.cssText = 'text-align:center;font-size:0.8rem;color:#666;margin-top:2rem;padding-top:1rem;border-top:1px solid #eee;';
    lastUpdated.textContent = 'Last updated: ' + new Date().toLocaleDateString();
    
    var content = document.querySelector('.wypl-content');
    if (content) {
        content.appendChild(lastUpdated);
    }
});