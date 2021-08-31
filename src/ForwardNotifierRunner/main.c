//
//  ForwardNotifier
//
//  Created by ren7995 on 2021-08-30 20:33:57
//

#include <dlfcn.h>
#include <spawn.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define FLAG_PLATFORMIZE (1 << 1)

void fixSetuid() {
    void *handle = dlopen("/usr/lib/libjailbreak.dylib", RTLD_LAZY);
    if(!handle) {
        return;
    }

    dlerror();
    typedef void (*fix_entitle_prt_t)(pid_t pid, uint32_t what);
    fix_entitle_prt_t enetitle_ptr = (fix_entitle_prt_t)dlsym(handle, "jb_oneshot_entitle_now");
    const char *dlsym_error = dlerror();
    if(dlsym_error) {
        return;
    }
    enetitle_ptr(getpid(), FLAG_PLATFORMIZE);

    dlerror();
    typedef void (*fix_setuid_prt_t)(pid_t pid);
    fix_setuid_prt_t setuid_ptr = (fix_setuid_prt_t)dlsym(handle, "jb_oneshot_fix_setuid_now");
    dlsym_error = dlerror();
    if(dlsym_error) {
        return;
    }

    setuid_ptr(getpid());
    setuid(0);
    setgid(0);
    setuid(0);
    setgid(0);
}

int main(int argc, char *argv[], char *envp[]) {
    if(argc != 2) return -1;

    setuid(0);
    if(getuid() != 0) {
        fixSetuid();
    }

    // Check arg
    if(strstr(argv[1], ".sh") == NULL) {
        fprintf(stderr, "Script path must end in .sh\n");
        abort();
    }
    // Get and check path
    char scriptPath[100] = "/Library/ForwardNotifier/Scripts/";
    strcat(scriptPath, argv[1]);
    if(access(scriptPath, F_OK) != 0) {
        fprintf(stderr, "Script (%s) does not exist or is inaccessible\n", scriptPath);
        abort();
    }

    pid_t pid;
    const char *args[] = {"bash", scriptPath, NULL};
    posix_spawn(&pid, "/usr/bin/bash", NULL, NULL, (char *const *)args, NULL);

    return 0;
}