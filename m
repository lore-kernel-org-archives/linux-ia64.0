From: Steve Lord <lord@sgi.com>
Date: Fri, 12 Oct 2001 15:24:06 +0000
Subject: [Linux-ia64] Re: SGI XFS 1.0.1-IA64 Preview Release 1 available for testing
Message-Id: <marc-linux-ia64-105590698805340@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Nate, have you tried recovery testing - see PV 838706 from Keith
Owens.

Steve

> The first preview release of SGI XFS 1.0.1-IA64 is available at:
> 
> ftp://oss.sgi.com/projects/xfs/download/testing/Release-1.0.1-IA64-PR1/
> 
> These files are currently undergoing BETA testing.  
> 
> RPMS/     Kernel RPMs based on:
>           - Linux 2.4.9 (Linus's tree)
>           - Trillian 2.4.9-010820
>           - XFS 2.4.9 010826
>           - kdb-v1.8a-2.4.9-ia64-010820
> 
> cmd_rpms/ Command RPMs built for IA64, including lvm tools
> cmd_tars/ Command tarballs built for IA64.  The lvm tarball is source.
> 
> configs/  The config file from the kernel RPMs.  Please check these
>           over to see if anything important is missing.
> 
> patches/  A patch against Linux-2.4.9-ia64-010820.  Separate patches are
>           available in the source RPM. 
> 
> This kernel is built with 16k pages.  
> 
> An installer is not available at this time.  We're still working on it.
> 
> -- 
> Nate Straz                                              nstraz@sgi.com
> sgi, inc                                           http://www.sgi.com/
> Linux Test Project                                  http://ltp.sf.net/



