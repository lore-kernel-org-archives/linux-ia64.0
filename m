From: Stephane Eranian <eranian@frankl.hpl.hp.com>
Date: Wed, 18 Dec 2002 23:35:54 +0000
Subject: Re: [Linux-ia64] installation help
Message-Id: <marc-linux-ia64-105590709805613@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805612@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805612@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Wed, Dec 18, 2002 at 03:25:17PM -0800, Jian Chen wrote:
> Hi,
> 
> I downoaded ski and nue, and installed with:
> 
> rpm -Uhv ski-0.943l-2.i386.rpm
> rpm -Uhv nue-1.1-1.i386.rpm
> rpm -Uhv nue-fs-1.2-1.i386.rpm
> 
> I verified my installation with hello.c, but found
> that the compiled binary file can't be executed. Does
> anyone know why?
> 
> My system is Redhat Linux 7.3, CPU Intel Pentium4
> 2.00GHZ, gcc version 2.96 20000731.
> 

On some systems, the RPM post install script does not properly
execute the init script necessary to get the IA-64 binary
executed by the simulator. It is very easy to fix.

As root, simply type:

# /etc/rc.d/init.d/ia64fmt start

Then you will be able to run the IA-64 binary inside the NUE environment.
Note that next time you reboot your system, the rc script will be executed
automatically.

-- 
-Stephane

