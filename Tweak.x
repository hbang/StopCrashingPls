#import <os/log.h>

static const char *exceptions[] = {
	"/Library/MobileSubstrate/DynamicLibraries/mrybootstrap.dylib",
	"/usr/lib/TweakInject/mrybootstrap.dylib",
	NULL
};

static BOOL isAllowed(const char *path) {
	for (const char **exception = exceptions; *exception; exception++) {
		if (strcmp(*exception, path) == 0)
			return YES;
	}
	return NO;
}

static BOOL hasPrefix(const char *string, const char *prefix) {
	return strncmp(prefix, string, strlen(prefix)) == 0;
}

%hookf(void *, dlopen, const char *path, int mode) {
	if ((hasPrefix(path, "/Library/MobileSubstrate/DynamicLibraries/") || hasPrefix(path, "/usr/lib/TweakInject/")) && !isAllowed(path)) {
		os_log(OS_LOG_DEFAULT, "stopcrashingpls: Loading of %{public}s was blocked.", path);
		return NULL;
	}
	return %orig;
}
