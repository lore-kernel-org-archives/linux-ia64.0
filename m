From: Stephane Eranian <eranian@hpl.hp.com>
Date: Thu, 16 Nov 2006 13:02:35 +0000
Subject: Re: How does the ski simulator resolves the dependency on shared libraries?
Message-Id: <20061116130235.GD18162@frankl.hpl.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <9b33a9230611152307x6580a290n652ee50d9a5bda0c@mail.gmail.com>
In-Reply-To: <9b33a9230611152307x6580a290n652ee50d9a5bda0c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hello,

On Thu, Nov 16, 2006 at 12:37:24PM +0530, sudhnesh adapawar wrote:
> Hey all,
>          How does the ski simulator resolves the dependency on shared
> libraries?
>              For e.g: I tried 'ls' command on xski but i failed to run it :

Ski does not resolve shared library for applications. Your 'ls' must be an satically
linked IA-64 binary. Aslo keep in mind that ski operates in one of two modes: system
or application. In the latter, you would do: xski ls.  You probably also need to specify
the absolute path if the binary is not in the current directory.

> [root@basemant /]# xski ls vmlinux simscsi=/var/ski-disks/sd
> ls - No such file or directory
> ls - No such file or directory
> xski: Could not open ls for reading
> [root@basemant /]# which ls
> alias ls='ls --color=tty'
>       /bin/ls
> [root@basemant /]# xski /bin/ls vmlinux simscsi=/var/ski-disks/sd
> /bin/ls - wrong architecture (3)
> xski: Could not open /bin/ls for reading
> [root@basemant /]#
> 
> Please kindly reply !
> 
> - Sudhnesh
> -
> To unsubscribe from this list: send the line "unsubscribe linux-ia64" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 

-Stephane
