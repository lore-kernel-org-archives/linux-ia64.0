From: Aron Griffis <aron@hp.com>
Date: Fri, 28 May 2004 21:41:05 +0000
Subject: lib64 in fedora glibc
Message-Id: <20040528214105.GK9115@mustard.zk3.dec.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

These snippets from the current fedora glibc.spec look suspicious to
me.. I was under the impression that ia64 would use /lib for 64-bit
and /lib32 for 32-bit (or something like that), but it looks like RH
is preparing to transition to lib64.

Patch4: %{name}-ia64-lib64.patch

%prep:
    %ifarch ia64
    %if "%{_lib}" = "lib64"
    %patch4 -p1
    %endif

%install:
    %ifarch ia64
    %if "%{_lib}" = "lib64"
    # Compatibility symlink
    mkdir -p $RPM_BUILD_ROOT/lib
    ln -sf /%{_lib}/ld-linux-ia64.so.2 $RPM_BUILD_ROOT/lib/ld-linux-ia64.so.2
    %endif
    %endif

%files:
    %ifarch ia64
    %if "%{_lib}" = "lib64"
    %dir /lib
    /lib/ld-linux-ia64.so.2
    %endif
    %endif

%changelog:
    * Thu May 20 2004 Jakub Jelinek <jakub@redhat.com> 2.3.3-29
    - use lib64 instead of lib on ia64 if %%{_lib} is defined to lib64

--
Aron Griffis
hp Linux and Open Source Lab

