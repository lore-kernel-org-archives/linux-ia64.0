From: Christoph Hellwig <hch@ns.caldera.de>
Date: Wed, 12 Sep 2001 11:58:33 +0000
Subject: Re: [Linux-ia64] Location of absolute IA32 shared objects.
Message-Id: <marc-linux-ia64-105590698805173@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805122@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805122@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, Sep 11, 2001 at 09:25:39PM +1000, Mark Goodwin wrote:
> RPM installs for ia32 apps/libs will need to use --prefix `cat /proc/ia32prefix`
> or whatever.
> If sysadmin subsequently changes the prefix, it wont work.
> better solution be an ia32 specifc version of /etc/ld.so.conf? Or perhaps the
> /proc file should allow multiple search paths?

That was discussed before - the real issue are IA32 programms that hardcode
pathes.

	Christoph

-- 
Of course it doesn't work. We've performed a software upgrade.

