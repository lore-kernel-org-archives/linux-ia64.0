From: Jack Steiner <steiner@sgi.com>
Date: Fri, 20 Oct 2006 02:03:32 +0000
Subject: Re: [PATCH] - Fix get_model_name() for mixed cpu type systems
Message-Id: <20061020020332.GB19263@sgi.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20061018212559.GA2965@sgi.com>
In-Reply-To: <20061018212559.GA2965@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> 
> While I was testing cpu-hotplug  (2.6.18-git tree), mistakenly I hot-plugged
> different-frequency-cpu.
> 	Booted with : Itanium2 1.6GHz
> 	Hot-added   : Itanium2 1.5GHz
> 
> What happend was ...hrtimer delayed.
> timers based on jiffies (ex. select()) worked well but timer based on hrtimer
> can't work. For example, sleep(1) sleeps very long..
> 
> Mixed-cpu system works well in other environment ?

FWIW, one of our primary test systems has:

 CPU  GEOID        FAMILY   MOD REV ARCH CPUFREQ ITCFREQ FSBFREQ L3-MB CORE THD NODE NASID  SHUB  PROM
   0  001c05#0a    Itanium2   1   5    0    1300    1300     400     3    0   0    0     0   1.2  4.70
   1  001c05#0c    Itanium2   1   5    0    1300    1300     400     3    0   0    0     0   1.2  4.70
   2  001c05#1a    Itanium2   1   5    0    1300    1300     400     3    0   0    1     2   1.2  4.70
...
  21  001c34#0c    Itanium2   1   5    0    1300    1300     325     3    0   0   14    28   1.1  4.70
  22  001c34#1a    Itanium2   1   5    0    1300    1300     325     3    0   0   15    30   1.1  4.70
  23  001c34#1c    Itanium2   1   5    0    1300    1300     400     3    0   0   15    30   1.1  4.70
  24  002c11#0a    Itanium2   2   2    0    1600    1600     400     6    0   0   16    32   1.2  4.70
  25  002c11#0c    Itanium2   2   2    0    1600    1600     400     6    0   0   16    32   1.2  4.70
  26  002c11#1a    Itanium2   2   2    0    1600    1600     426     6    0   0   17    34   1.2  4.70
...
  31  002c14#1c    Itanium2   2   2    0    1600    1600     426     6    0   0   19    38   1.2  4.70
  32  002c17#0a    Itanium2   2   2    0    1500    1500     400     4    0   0   20    40   1.2  4.70
  33  002c17#0c    Itanium2   2   2    0    1500    1500     400     4    0   0   20    40   1.2  4.70
  34  002c17#1a    Itanium2   2   2    0    1500    1500     461     4    0   0   21    42   1.2  4.70
  35  002c17#1c    Itanium2   2   2    0    1500    1500     666     4    0   0   21    42   1.2  4.70
  36  002c27#0a    Itanium2   2   2    0    1500    1500     666     4    0   0   22    44   1.2  4.70
...
  40  003c11#0a    Itanium2   0   7    0     900     900     400     1    0   0   24    48   1.1  4.70
  41  003c11#0c    Itanium2   0   7    0     900     900     400     1    0   0   24    48   1.1  4.70
  42  003c11#1a    Itanium2   0   7    0     900     900     400     1    0   0   25    50   1.1  4.70

I've never noticed a problem with normal operation. I have NOT tried hot-add.

-- jack
