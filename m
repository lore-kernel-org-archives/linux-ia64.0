From: Bjorn Helgaas <bjorn_helgaas@hp.com>
Date: Thu, 29 May 2003 22:38:38 +0000
Subject: Re: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706083@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thursday 29 May 2003 3:47 pm, Luck, Tony wrote:
> ... What benefit do we gain at the application
> level by making all the mca/init/cmci/cpei files
> visible on a per-cpu basis?

I really like the idea of having a file be an exact binary
image of the buffer from SAL, i.e., no extra headers, etc.

> For platform level errors, this just causes confusion
> as the same record is definitely available on all cpus.
> But if your application is "poll"ing all the files, only
> one needs to read&clear.

If the application is using poll(2), it will only see the
record available on one of the files.  If the application
does its own periodic polling *and* it reads all the
files before clearing any of them, it will see several
copies.

> ...  If all the error records were funneled into a
> single file, would we lose anything?

There is a certain appeal to using a single file, at least from
the application perspective.  Let's run this up the flagpole
and see whether anybody salutes:

	- we export two files: "control" and "data"
	- app uses poll(2) on "control"
	- SAL log events set a bit for CPU and event type
	  and do a wakeup
	- app returns from poll()
	- app reads "control"
	- kernel supplies "cpu 5 cpe" as read(2) data
	- app writes same data ("cpu 5 cpe") to "control"
	- app reads "data"
	- kernel calls GET_STATE_INFO and supplies
	  raw data to app
	- app writes "clear cpu 5 cpe" to "control"
	- kernel clears CPU/event bit, calls CLEAR_STATE_INFO,
	  and calls GET_STATE_INFO, does wakeup if more data

Is that too ugly for words?  It keeps the unadorned SAL data,
requires only two files, and could probably even be driven from
a shell script (if we make read(2) on "control" blocking).  It
feels sort of Plan 9-ish, which is always appealing.  Plus, it
avoids the problem of having hundreds of "cpuXXXX" directories
on all those monster SGI boxes :-)

There might be fairness issues if events occur faster than the
app reads them -- might have to round-robin through the
CPUs when supplying "control" data.  Or we could use a pair
of files for each type of event, i.e., /proc/sal/mca/{control,data}.

Bjorn


