From: Mark Goodwin <markgw@sgi.com>
Date: Tue, 23 Jan 2001 06:02:14 +0000
Subject: [Linux-ia64] ia32 RPMs on ia64 systems
Message-Id: <marc-linux-ia64-105590693005088@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

I have an ia32 RPM that I need to support on ia64 - it has to remain ia32
due to some 3rd party libs for which I don't have the src (don't flame me).

At the moment I have to force RPM to let me install it, with horrible things like
rpm --ignorearch --nodeps --badreloc \
    --relocate /usr/lib=/usr/i386-glibc21-linux/usr/lib -i <ia32package>

or depending on your ia64 distribution, I may need to relocate to /usr/ia32
or for some other distro, probably to somewhere else ...

Could someone from the each distro (redhat, suse, turbo, and deb) please tell
me what they are planning to do about ia32 packaging/installation support? Can
we please standardize on the relocation directories? At the moment, ia32 binaries
work just fine - it's the file system standards base and packaging support that
seem to be missing.. thanks, I'll summarize to the list.

--
Mark Goodwin
SGI Engineering.


