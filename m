From: Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>
Date: Mon, 28 Oct 2002 06:58:53 +0000
Subject: Re: [Linux-ia64] build a bootable kernel
Message-Id: <marc-linux-ia64-105590709805273@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Do "strip vmlinux"
or delete -g option in Makefile
and then compress the kernel with gzip or bzip2 if you want.

Kimi

On Mon, 28 Oct 2002 14:49:11 +0800
"dai yiyang" <daiyiyang@hotmail.com> wrote:

> Hi :
> 
>    I have build a 2.5.39 kernel under redhat 7.2 use "make vmlinux" , the 
> output file vmlinux is 55M!  and seems cannot be loaded by elilo .
>    Per my check the original kernel file default installed on the system is 
> only 1M , I think it should been compressed .
>    Anybody can provide me the right step to build a bootable kernel under 
> ia64 ?

-- 
Kimio Suganuma <k-suganuma@mvj.biglobe.ne.jp>


