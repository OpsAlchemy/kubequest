# Docker ENTRYPOINT and CMD: Complete Guide - What Works and What Doesn't

## Table of Contents
1. [Fundamental Concepts](#fundamental-concepts)
2. [Syntax Forms Explained](#syntax-forms-explained)
3. [Interaction Patterns](#interaction-patterns)
4. [What Works](#what-works)
5. [What Doesn't Work](#what-doesnt-work)
6. [Best Practices](#best-practices)
7. [Real-World Examples](#real-world-examples)
8. [Troubleshooting Guide](#troubleshooting-guide)

## Fundamental Concepts

### ENTRYPOINT
- **Purpose**: Defines the container's main executable that always runs
- **Behavior**: Difficult to override (requires `--entrypoint` flag)
- **Use Case**: For the core application process that should always run

### CMD
- **Purpose**: Provides default arguments or a default command
- **Behavior**: Easily overridden by command-line arguments to `docker run`
- **Use Case**: For default parameters or easily changeable commands

## Syntax Forms Explained

### Exec Form (Recommended)
```dockerfile
ENTRYPOINT ["executable", "param1", "param2"]
CMD ["param3", "param4"]
```
- **Advantages**: Proper signal handling, no shell processing overhead
- **Process hierarchy**: Direct execution without `/bin/sh` parent process

### Shell Form
```dockerfile
ENTRYPOINT command param1 param2
CMD command param1 param2
```
- **Behavior**: Docker wraps with `/bin/sh -c "command param1 param2"`
- **Disadvantages**: Poor signal handling, additional process layer

## Interaction Patterns

### Pattern 1: ENTRYPOINT + CMD (Most Common)
```dockerfile
ENTRYPOINT ["main-executable"]
CMD ["default-arg1", "default-arg2"]
```
- **Result**: `main-executable default-arg1 default-arg2`
- **Override**: `docker run image custom-arg` → `main-executable custom-arg`

### Pattern 2: ENTRYPOINT Only
```dockerfile
ENTRYPOINT ["main-executable", "fixed-arg"]
```
- **Result**: `main-executable fixed-arg`
- **Append**: `docker run image extra-arg` → `main-executable fixed-arg extra-arg`

### Pattern 3: CMD Only
```dockerfile
CMD ["executable", "arg1", "arg2"]
```
- **Result**: `executable arg1 arg2`
- **Full override**: `docker run image new-command` → `new-command`

### Pattern 4: Neither
- Uses base image's default command (often `/bin/bash` or `/bin/sh`)

## What Works

### ✅ Shell Integration with Single Command String
```dockerfile
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo 'hello world' && sleep 10"]
```
**Works because**: The entire CMD becomes a single argument to `-c`

### ✅ Direct Binary Execution
```dockerfile
ENTRYPOINT ["echo", "hello"]
```
**Works because**: No shell involved, direct execution

### ✅ Parameter Combination
```dockerfile
ENTRYPOINT ["sleep"]
CMD ["30"]
```
**Works because**: Clean parameter passing without shell

### ✅ Interpreter with File Execution
```dockerfile
ENTRYPOINT ["python", "app.py"]
CMD ["--verbose"]
```
**Works because**: File execution doesn't require `-c` flag

### ✅ Shell Form for Simple Commands
```dockerfile
CMD echo "Hello World"
```
**Works for**: Basic commands where signal handling isn't critical

## What Doesn't Work

### ❌ Multiple Arguments with sh -c
```dockerfile
ENTRYPOINT ["/bin/sh", "-c"]
CMD ["echo", "hello", "world"]
```
**Fails because**: `sh -c` expects a single command string, not multiple arguments

### ❌ Invalid Executable
```dockerfile
ENTRYPOINT ["-c"]
CMD ["echo hello"]
```
**Fails because**: `-c` is not an executable binary

### ❌ Mixed Shell and Exec Forms Unpredictably
```dockerfile
ENTRYPOINT ["/bin/sh", "-c"]
CMD echo "hello"
```
**Problematic**: Inconsistent behavior and signal handling issues

### ❌ Shell Form for Critical Processes
```dockerfile
ENTRYPOINT java -jar app.jar
```
**Problem**: SIGTERM signals won't reach your Java application

### ❌ CMD Override with ENTRYPOINT Expecting Parameters
```dockerfile
ENTRYPOINT ["echo", "Prefix:"]
```
```bash
docker run image # Works: "Prefix:"
docker run image Hello # Works: "Prefix: Hello"
docker run image --help # Broken: "Prefix: --help" (not helpful output)
```

## Best Practices

### 1. Prefer Exec Form
```dockerfile
# Good
ENTRYPOINT ["executable", "arg1", "arg2"]
CMD ["arg3", "arg4"]

# Avoid unless needed
ENTRYPOINT executable arg1 arg2
```

### 2. Use Wrapper Scripts for Complex Logic
```dockerfile
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

### 3. Design for Overridability
```dockerfile
# Good - allows easy override
ENTRYPOINT ["python", "app.py"]
CMD ["--help"]

# Problematic - hard to override behavior
ENTRYPOINT ["python", "app.py", "--production"]
```

### 4. Handle Signals Properly
```dockerfile
# Good - signals reach your app
ENTRYPOINT ["node", "server.js"]

# Bad - signals go to shell, not your app
ENTRYPOINT node server.js
```

### 5. Use JSON Array for CMD with ENTRYPOINT
```dockerfile
# Correct
ENTRYPOINT ["echo"]
CMD ["hello world"]

# Incorrect (will not work as expected)
ENTRYPOINT ["echo"]
CMD hello world
```

## Real-World Examples

### Web Server Pattern
```dockerfile
ENTRYPOINT ["nginx", "-g", "daemon off;"]
CMD ["-c", "/etc/nginx/nginx.conf"]
```

### Application Server Pattern
```dockerfile
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar"]
CMD ["app.jar", "--spring.profiles.active=production"]
```

### Script Runner Pattern
```dockerfile
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["start"]
```

### Development vs Production
```dockerfile
ENTRYPOINT ["docker-entrypoint.sh"]
# Development default
CMD ["dev", "--watch"]
# Production override
# docker run image prod --cluster
```

## Troubleshooting Guide

### Problem: Command not found
**Cause**: Shell form not finding executable in PATH
**Solution**: Use full paths or ensure executable is in PATH

### Problem: Signals not reaching application
**Cause**: Using shell form instead of exec form
**Solution**: Convert to exec form `["executable", "arg"]`

### Problem: CMD arguments not being passed correctly
**Cause**: Incorrect combination of ENTRYPOINT and CMD forms
**Solution**: Use consistent exec form for both

### Problem: Container exits immediately
**Cause**: Main process exits (no long-running process in ENTRYPOINT/CMD)
**Solution**: Ensure your command doesn't exit immediately

### Problem: Environment variables not expanding
**Cause**: Using exec form prevents shell variable expansion
**Solution**: Use shell form or handle expansion in wrapper script

## Advanced Patterns

### Health Check Integration
```dockerfile
ENTRYPOINT ["app"]
CMD ["--health-check-port=8080"]
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/health || exit 1
```

### Multi-stage Command Pattern
```dockerfile
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["source /app/env.sh && exec /app/main"]
```

### Migration Then Start Pattern
```dockerfile
ENTRYPOINT ["/bin/bash", "-c"]
CMD ["if [ ! -f /data/migrated ]; then ./migrate.sh && touch /data/migrated; fi && exec ./app"]
```

This comprehensive guide should help you understand what works, what doesn't, and how to properly use ENTRYPOINT and CMD in your Docker containers.