From: Keith Owens <kaos@ocs.com.au>
Date: Wed, 12 Dec 2001 00:13:07 +0000
Subject: Re: [Linux-ia64] updated salinfo patch
Message-Id: <marc-linux-ia64-105590698805686@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805685@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805685@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 11 Dec 2001 16:01:36 -0800, 
Jesse Barnes <jbarnes@sgi.com> wrote:
>+MODULE_AUTHOR("Jesse Barnes <jbarnes@sgi.com>");
>+MODULE_DESCRIPTION("/proc interface to IA-64 SAL features");

Better add MODULE_LICENSE("GPL");

>+int salinfo_read(char *page, char **start, off_t off, int count, int *eof, void *data);

Is there any reason to expose salinfo_read, AFAICT it can be static.
If you want to expose that function, you need EXPORT_SYMBOL(salinfo_read)
and salinfo.o must be added to export-objs.


