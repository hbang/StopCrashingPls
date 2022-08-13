#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <os/log.h>
#import <string.h>
#import <stdlib.h>

static BOOL hasPrefix(const char *string, const char *prefix) {
	return string != NULL && strncmp(prefix, string, strlen(prefix)) == 0;
}

static char *executable;

static BOOL isProcess(const char *name) {
	if (executable == NULL) {
		uint32_t bufsize = 0;
		_NSGetExecutablePath(NULL, &bufsize);
		char buffer[bufsize];
		_NSGetExecutablePath(buffer, &bufsize);
		executable = malloc(sizeof(buffer));
		strncpy(executable, buffer, sizeof(buffer));
	}
	return executable != NULL && strcmp(executable, name) == 0;
}

%hookf(void *, dlopen, const char *path, int mode) {
	if (
		(hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries") || hasPrefix(path, "/usr/lib/TweakInject")) &&
		(!isProcess("/usr/libexec/MobileGestaltHelper") || (
			strcmp(path, "/Library/MobileSubstrate/DynamicLibraries/mrybootstrap.dylib") != 0 &&
			strcmp(path, "/usr/lib/TweakInject/mrybootstrap.dylib") != 0 &&
			strcmp(path, "/Library/MobileSubstrate/DynamicLibraries/libSandySupport.dylib") != 0 &&
			strcmp(path, "/usr/lib/TweakInject/libSandySupport.dylib") != 0
		))
	) {
		os_log(OS_LOG_DEFAULT, "stopcrashingpls: Loading of %{public}s was blocked.", path);
		return NULL;
	}
	return %orig;
}
