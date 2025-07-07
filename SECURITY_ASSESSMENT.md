# Security Assessment: Redmine Periodic Jobs Plugin

## Executive Summary

The Redmine Periodic Jobs plugin contains **multiple critical security vulnerabilities** that could allow attackers to:
- Read arbitrary files from the server filesystem
- Execute Cross-Site Scripting (XSS) attacks
- Potentially escalate privileges

## Critical Vulnerabilities Identified

### 1. **CRITICAL: Path Traversal / Local File Inclusion (LFI)**

**Location:** `app/controllers/periodic_jobs_controller.rb`, lines 13-14

```ruby
path_to_file = File.join(Rails.root, @periodic_job.path)
@job_content = File.read(path_to_file)
```

**Issue:** The plugin directly uses user-controlled input (`@periodic_job.path`) to construct file paths without any validation or sanitization. This allows path traversal attacks.

**Attack Vector:**
An attacker with admin privileges could create a periodic job with a malicious path such as:
- `../../../etc/passwd` - to read system files
- `../../../config/database.yml` - to read database credentials
- `../../../config/secrets.yml` - to read application secrets

**Impact:** Complete server file system disclosure, potential credential theft, exposure of sensitive configuration files.

### 2. **HIGH: Cross-Site Scripting (XSS)**

**Location:** `app/views/periodic_jobs/show.html.erb`, line 14

```erb
<p><%= simple_format(@job_content) %></p>
```

**Issue:** File content read from the filesystem is displayed directly in the browser without proper HTML escaping. The `simple_format` helper preserves HTML content.

**Attack Vector:**
- An attacker could create a periodic job pointing to a file containing malicious JavaScript
- When any admin views the job, the JavaScript executes in their browser
- This could lead to session hijacking, credential theft, or further privilege escalation

**Impact:** Admin session compromise, potential data theft, further system compromise.

### 3. **MEDIUM: Insufficient Input Validation**

**Location:** `app/models/periodic_job.rb`

**Issue:** The model lacks proper validation for the `path` field:
- No validation to ensure paths are safe
- No whitelist of allowed directories
- No checks for path traversal sequences

**Impact:** Enables the path traversal vulnerability described above.

### 4. **MEDIUM: Unsafe File Operations**

**Location:** `app/controllers/periodic_jobs_controller.rb`, lines 13-19

**Issue:** 
- File operations are performed without checking if the file exists in a safe location
- Error handling reveals file path information in logs
- No rate limiting for file read operations

### 5. **LOW: Information Disclosure**

**Location:** `app/controllers/periodic_jobs_controller.rb`, line 17

```ruby
puts "!!! #{path_to_file}"
```

**Issue:** File paths are written to logs/console output, potentially exposing sensitive information about the filesystem structure.

## Additional Security Concerns

### Access Control
- While the plugin requires admin access (`before_action :require_admin`), it still allows admin users to read arbitrary files
- No additional authorization checks for file access
- No audit logging of file access attempts

### CSRF Protection
- Standard Rails CSRF protection should be in place, but explicit verification would be recommended for sensitive operations

## Recommended Fixes

### 1. **Immediate Actions (Critical)**

#### Fix Path Traversal:
```ruby
# In periodic_jobs_controller.rb
def show
  @periodic_job = PeriodicJob.find(params[:id])
  
  # Validate and sanitize the path
  safe_path = validate_file_path(@periodic_job.path)
  return render_404 unless safe_path
  
  path_to_file = File.join(Rails.root, safe_path)
  
  # Additional security check
  unless path_to_file.start_with?(Rails.root)
    render_404
    return
  end
  
  begin
    @job_content = File.read(path_to_file)
  rescue => e
    Rails.logger.warn "File read error for job #{@periodic_job.id}: #{e.message}"
    @job_content = "Error reading script file."
  end
end

private

def validate_file_path(path)
  # Remove any path traversal attempts
  clean_path = path.gsub(/\.\.\//, '').gsub(/\.\.\\/, '')
  
  # Whitelist allowed directories (example)
  allowed_prefixes = ['scripts/', 'jobs/', 'cron/']
  return nil unless allowed_prefixes.any? { |prefix| clean_path.start_with?(prefix) }
  
  clean_path
end
```

#### Fix XSS:
```erb
<!-- In show.html.erb -->
<div class="box">
  <pre><%= h(@job_content) %></pre>
</div>
```

### 2. **Model Validation**
```ruby
# In periodic_job.rb
class PeriodicJob < ApplicationRecord
  include Redmine::SafeAttributes

  safe_attributes :title, :author_id, :path, :periodicity

  belongs_to :author, :class_name => 'User'

  validates :path, presence: true, format: { 
    with: /\A(scripts|jobs|cron)\/[a-zA-Z0-9_\-\/\.]+\z/,
    message: 'must be in allowed directories and contain only safe characters'
  }
  
  validate :path_not_traversal

  default_scope { order('id desc') }

  private

  def path_not_traversal
    if path.present? && (path.include?('..') || path.include?('~'))
      errors.add(:path, 'cannot contain path traversal sequences')
    end
  end
end
```

### 3. **Additional Security Measures**

- Implement a whitelist of allowed directories for job scripts
- Add audit logging for all file access attempts
- Consider implementing read-only access with a dedicated service account
- Add rate limiting for file operations
- Implement Content Security Policy (CSP) headers

## Risk Assessment

| Vulnerability | Severity | Exploitability | Impact |
|---------------|----------|----------------|---------|
| Path Traversal | **Critical** | High | Server compromise |
| XSS | **High** | Medium | Admin compromise |
| Input Validation | **Medium** | High | Enables other attacks |
| Information Disclosure | **Low** | Low | Information leakage |

## Conclusion

This plugin poses **significant security risks** and should not be used in production without immediately implementing the recommended fixes. The combination of path traversal and XSS vulnerabilities could lead to complete server compromise.

**Priority:** Fix the path traversal vulnerability immediately, followed by the XSS issue. Consider temporarily disabling the plugin until these issues are resolved.