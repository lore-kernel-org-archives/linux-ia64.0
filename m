From: Keith Owens <kaos@ocs.com.au>
Date: Tue, 16 Oct 2001 06:47:26 +0000
Subject: Re: [Linux-ia64] lost printk's
Message-Id: <marc-linux-ia64-105590698805348@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590698805347@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590698805347@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Tue, 16 Oct 2001 08:16:05 +0200, 
Christian Hildner <christian.hildner@hob.de> wrote:
>I want to write a low level driver for linux on ia64. During testing the
>machine often crashes very heavily. After reboot most of the printk's
>that have been done before the crash are lost. Maybe they are hold in
>the disk cache when the crash occurs.

Still in memory.  printk() -> console drivers -> kernel log buffer ->
klogd (user space) -> syslogd -> kernel I/O subsystem -> disk.  Crash
too soon and the data does not get to disk.

>Does anybody know how to get the printk's written on disk?

If a crash kills the user space tasks or the disk I/O subsystem then
your printk does not get to disk.  Use a serial console and capture the
output on a second machine, that goes printk() -> console drivers ->
serial line.  Still no guarantees that you get all output, some crashes
kill the serial line driver as well.  If your problem is that bad then
use the kernel debugger, ftp://oss.sgi.com/projects/kdb/download/ia64.


