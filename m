From: "Luck, Tony" <tony.luck@intel.com>
Date: Thu, 29 May 2003 23:33:49 +0000
Subject: RE: [Linux-ia64] SAL error record logging/decoding
Message-Id: <marc-linux-ia64-105590723706084@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705660@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705660@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> There is a certain appeal to using a single file, at least from
> the application perspective.  Let's run this up the flagpole
> and see whether anybody salutes:
> 
> 	- we export two files: "control" and "data"
> 	- app uses poll(2) on "control"
> 	- SAL log events set a bit for CPU and event type
> 	  and do a wakeup
> 	- app returns from poll()
> 	- app reads "control"
> 	- kernel supplies "cpu 5 cpe" as read(2) data
> 	- app writes same data ("cpu 5 cpe") to "control"
> 	- app reads "data"
> 	- kernel calls GET_STATE_INFO and supplies
> 	  raw data to app
> 	- app writes "clear cpu 5 cpe" to "control"
> 	- kernel clears CPU/event bit, calls CLEAR_STATE_INFO,
> 	  and calls GET_STATE_INFO, does wakeup if more data
> 
> Is that too ugly for words?  It keeps the unadorned SAL data,
> requires only two files, and could probably even be driven from
> a shell script (if we make read(2) on "control" blocking).  It
> feels sort of Plan 9-ish, which is always appealing.  Plus, it
> avoids the problem of having hundreds of "cpuXXXX" directories
> on all those monster SGI boxes :-)
> 
> There might be fairness issues if events occur faster than the
> app reads them -- might have to round-robin through the
> CPUs when supplying "control" data.  Or we could use a pair
> of files for each type of event, i.e., /proc/sal/mca/{control,data}.

Seems odd that we read "cpu 5 cpe" from the "control" file, and then
turn around to write the same thing back to the same file.

Perhaps you are overloading the function of the control file?  With
three files: {event,control,data} you get all the above functionality,
but with a simpler to understand interface.

Applications block reading the "event" file (or use poll(2) on it) to
find out that it is worth reading.  When they read, they see the "cpu
5 cpe" type message.  They write that to "control", and then read from
"data".

Or, back to two files: {event,data} ... we read from "event" to see
what happened.  Writing to "data" controls what will be read from "data".

-Tony


