From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 20 Oct 2006 01:54:06 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061020105406.b0c67950.kamezawa.hiroyu@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, 19 Oct 2006 15:57:20 -0500 (CDT)
Russ Anderson <rja@sgi.com> wrote:

> Attached is a test patch for supporting mixed CPUs.  It changes pmu_conf to
> an array, to keep track of the different CPU characteristics.  At initialization
> information is saved for each of the CPUs.
> 
> Routines have been modified to access the corresponding CPU information.  There
> are likely mistakes accessing the correct CPU, but it is a start.
> 
> It boots on a mixed CPU system.  I can help test.
>
(maybe off topic ?)

While I was testing cpu-hotplug  (2.6.18-git tree), mistakenly I hot-plugged
different-frequency-cpu.
	Booted with : Itanium2 1.6GHz
	Hot-added   : Itanium2 1.5GHz

What happend was ...hrtimer delayed.
timers based on jiffies (ex. select()) worked well but timer based on hrtimer
can't work. For example, sleep(1) sleeps very long..

Mixed-cpu system works well in other environment ?

-Kame

