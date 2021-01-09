#import <os/log.h>
#import <dlfcn.h>

static BOOL hasPrefix(const char *string, const char *prefix) {
	return strncmp(prefix, string, strlen(prefix)) == 0;
}

%hookf(void *, dlopen, const char *path, int mode) {
	if (path != NULL &&
		(hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries") || hasPrefix(path, "/usr/lib/TweakInject")) &&
		strcmp(path, "/Library/MobileSubstrate/DynamicLibraries/mrybootstrap.dylib") != 0 &&
		strcmp(path, "/usr/lib/TweakInject/mrybootstrap.dylib") != 0) {
		os_log(OS_LOG_DEFAULT, "stopcrashingpls: Loading of %{public}s was blocked.", path);
		return NULL;
	}
	return %orig;
}
