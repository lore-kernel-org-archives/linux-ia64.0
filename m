From: Michael Madore <mmadore@turbolinux.com>
Date: Sat, 24 Feb 2001 18:45:03 +0000
Subject: Re: [Linux-ia64] Re: Lockups on 2.4.1
Message-Id: <marc-linux-ia64-105590693005198@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590693005175@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590693005175@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi,

On Sat, Feb 24, 2001 at 03:44:07PM +0100, Francis Galiegue wrote:

> Speaking of help, BTW...
> 
> 1. what does VHPT mean anyway?

VHPT is an acronym for Virtual Hash Page Table.  It is an in memory
extension to the processor's translation lookaside buffer.  On a TLB miss,
the CPU can optionally search the VHPT for a translation.  I believe in
Linux, the short-format is used.  For details, refer to:

Intel IA-64 Architecture
Software Developers Manual
Volume 2: IA-64 System Architecture
Section 4.1.5: Virtual Hash Page Table (VHPT)

-- 
Mike Madore
Software Engineer
TurboLinux, Inc.

