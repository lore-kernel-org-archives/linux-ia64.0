From: Arun Sharma <arun.sharma@intel.com>
Date: Thu, 15 Apr 2004 21:02:06 +0000
Subject: Re: 32 bit application on IA-64 Linux
Message-Id: <407EF84E.9090304@intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
In-Reply-To: <20040412042150.30706.qmail@web13122.mail.yahoo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On 4/14/2004 9:01 PM, Peter Chubb wrote:

> Both dpkg and rpm allow you to specify a root directory; just specify
> /emul/ia32-linux 

# rpm -qi gcc
Name        : gcc                          Relocations: (not relocatable)
[...]

gcc is usually not relocatable. So one might have to use a "hack" such as rpm2cpio. I used chroot /emul/ia32-linux. But that requires a minimal package database is already setup under /emul/ia32-linux.

	-Arun

