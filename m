From: Keith Owens <kaos@sgi.com>
Date: Tue, 11 Nov 2003 00:25:27 +0000
Subject: Re: [PATCH] enable platform dependent MCA handling
Message-Id: <marc-linux-ia64-106851034925692@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-106850974125144@msgid-missing>
In-Reply-To: <marc-linux-ia64-106850974125144@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 Nov 2003 09:12:20 +0900, 
Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com> wrote:
>This is a patch that makes #ifdef mechanism in /arch/ia64/kernel/mca.c
>to work properly, and enable switching platform dependent error handling.
>For example, this supports OS to have an OEM call-back function for MCAs.
>Since this is a roughly scratched prototype, please give me your comments.

Defining any platform specific handlers at compile time is a problem for
generic kernels.  If you want a generic ia64 kernel (CONFIG_IA64_GENERIC=y)
to run on any hardware then all the platform specific code should be
chosen at run time, not at compile time.  That is, use ia64_platform_is()
to select platform specific code at run time.

