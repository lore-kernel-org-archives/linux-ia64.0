From: Grant Grundler <iod00d@hp.com>
Date: Tue, 31 Jan 2006 21:55:21 +0000
Subject: Re: [openib-general] Re: SDP perf drop with 2.6.15
Message-Id: <20060131215521.GA11678@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20060112195004.GK3106@esmail.cup.hp.com>
In-Reply-To: <20060112195004.GK3106@esmail.cup.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 12, 2006 at 11:50:04AM -0800, Grant Grundler wrote:
...
> 	I can't explain why q-syscollect *improves* perf by ~11 to 17%.

Kudos to Stephane Eranian for sorting this out.

Execute summary:
	Rebooting with "nohalt" kernel option gets me the full performance.

Gory details:
By default, ia64-linux goes to a "low power state" (no jokes about
this please) in the idle loop. This is implemented with form of
"halt" instruction.  Perfmon subsystem disables use of "halt" since
older (and possibly current) PAL support for "halt" was broken and it
would break the Performance Monitoring HW state. Please ask Stephane
offline if you need more details.

Stephane also commented that this might be an issue with other architectures
as well if they have a low power state. The transition from low power to
"normal" will have a cost on every architecture. And every interrupt is
likely to incur that cost. This is a real problem for benchmarking where
"latency" (ie we idle for very short periods of time) is hurt as I saw
with netperf TCP_RR.

Q to ia64-linux: since perfmon can enable/disable this on the fly, can
I add a /sys hook to do the same from userspace?
Where under /sys could this live?

cheers,
grant

> Details:
> Since I prefer q-syscollect:
> grundler@gsyprf3:~/openib-perf-2006/rx2600-r4929$ LD_PRELOAD=/usr/local/lib/libsdp.so q-syscollect /usr/local/bin/netperf -p 12866 -l 60 -H 10.0.0.30 -t TCP_RR -T 1,1 -c -C -- -r 1,1 -s 0 -S 0
> libsdp.so: $LIBSDP_CONFIG_FILE not set. Using /usr/local/etc/libsdp.conf
> libsdp.so: $LIBSDP_CONFIG_FILE not set. Using /usr/local/etc/libsdp.conf
> bind_to_specific_processor: enter
> TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.30 (10.0.0.30) port 0 AF_INET
> Local /Remote
> Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
> Send   Recv   Size    Size   Time    Rate     local  remote local   remote
> bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr
> 
> 16384  87380  1       1      60.00   16300.11  10.53  8.26   12.925  10.137
> 
> Wierd. Performance jumps from 13900 to 16300 (+2400 or +%17).
> Hrm...something got me to look at /proc/interrupts and I see that
> mthca is interrupting on CPU0 now:
>  70:  644084899          0       PCI-MSI-X  ib_mthca (comp)
>  71:          8          0       PCI-MSI-X  ib_mthca (async)
>  72:      27247          0       PCI-MSI-X  ib_mthca (cmd)
> 
> Retest with -T 0,1 :
> 
> 16384  87380  1       1      60.00   17557.94  6.06   10.88  6.909   12.390
> 
> And again -T 0,1 but without q-syscollect:
> 16384  87380  1       1      60.00   15891.41  6.13   7.61   7.713   9.571 
> 
> Now with -T 0,0:
> 16384  87380  1       1      60.00   20719.03  5.93   5.26   5.724   5.076 
> 
> with -T 0,0 and without q-syscollect:
> 16384  87380  1       1      60.00   18553.61  5.73   5.36   6.181   5.782 
> 
> That's +11% on the last set.
> I'm stumped why q-syscollect would *improve* performance.
...
