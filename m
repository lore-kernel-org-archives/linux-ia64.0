From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Mon, 28 Oct 2002 16:41:06 +0000
Subject: Re: [Linux-ia64] build a bootable kernel
Message-Id: <marc-linux-ia64-105590709805277@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805272@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805272@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Mon, Oct 28, 2002 at 05:42:59PM +0800, dai yiyang wrote:
> thanks for your help
> the kernel file has been built .
> but how to load the kernel during system boot time ?
> I have edit the elilo.conf file add the new kernel's path .
> but the the system halted at "umcompressed kernel ......ok ."
> 
What kind of machine are you trying to boot?
What is the .config file used to build the kernel?
What is the content of elilo.conf?

With this information I may be able to tell you what's wrong.

Thanks.

-- 
-Stephane

