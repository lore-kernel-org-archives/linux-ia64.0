From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 16:16:04 +0000
Subject: Re: [Linux-ia64] IA-32 emulation patch: rlim.patch
Message-Id: <marc-linux-ia64-105590723706074@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705996@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705996@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 22 May 2003 7:39 pm, Arun Sharma wrote:
> rlim_cur/rlim_max should be defined as unsigned integers to be
> compatible with native i386.

I applied this for 2.4.

