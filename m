From: Grant Grundler <iod00d@hp.com>
Date: Thu, 12 Jan 2006 19:50:04 +0000
Subject: Re: SDP perf drop with 2.6.15
Message-Id: <20060112195004.GK3106@esmail.cup.hp.com>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

On Thu, Jan 12, 2006 at 09:18:03AM +0200, Michael S. Tsirkin wrote:
> > Makes me think it's a change in the interrupt code path.
> > Any clues on where I might start with this?
> 
> oprofile should show where we are spending the time.

Executive summary:
	Silly me. interrupt bindings changed and I didn't check after rolling
	to 2.6.15 (from 2.6.14). That explains the increase cpu utilization
	with lower performance.
	Getting similar performance with -T 0,0 (2.6.15) vs -T 1,1 (2.6.14).

	I can't explain why q-syscollect *improves* perf by ~11 to 17%.
	I cc'd linux-ia64 hoping someone might explain it.

Details:
Since I prefer q-syscollect:
grundler@gsyprf3:~/openib-perf-2006/rx2600-r4929$ LD_PRELOAD=/usr/local/lib/libsdp.so q-syscollect /usr/local/bin/netperf -p 12866 -l 60 -H 10.0.0.30 -t TCP_RR -T 1,1 -c -C -- -r 1,1 -s 0 -S 0
libsdp.so: $LIBSDP_CONFIG_FILE not set. Using /usr/local/etc/libsdp.conf
libsdp.so: $LIBSDP_CONFIG_FILE not set. Using /usr/local/etc/libsdp.conf
bind_to_specific_processor: enter
TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 10.0.0.30 (10.0.0.30) port 0 AF_INET
Local /Remote
Socket Size   Request Resp.  Elapsed Trans.   CPU    CPU    S.dem   S.dem
Send   Recv   Size    Size   Time    Rate     local  remote local   remote
bytes  bytes  bytes   bytes  secs.   per sec  % S    % S    us/Tr   us/Tr

16384  87380  1       1      60.00   16300.11  10.53  8.26   12.925  10.137

Wierd. Performance jumps from 13900 to 16300 (+2400 or +%17).
Hrm...something got me to look at /proc/interrupts and I see that
mthca is interrupting on CPU0 now:
 70:  644084899          0       PCI-MSI-X  ib_mthca (comp)
 71:          8          0       PCI-MSI-X  ib_mthca (async)
 72:      27247          0       PCI-MSI-X  ib_mthca (cmd)

Retest with -T 0,1 :

16384  87380  1       1      60.00   17557.94  6.06   10.88  6.909   12.390

And again -T 0,1 but without q-syscollect:
16384  87380  1       1      60.00   15891.41  6.13   7.61   7.713   9.571 

Now with -T 0,0:
16384  87380  1       1      60.00   20719.03  5.93   5.26   5.724   5.076 

with -T 0,0 and without q-syscollect:
16384  87380  1       1      60.00   18553.61  5.73   5.36   6.181   5.782 

That's +11% on the last set.
I'm stumped why q-syscollect would *improve* performance.
Maybe someone on linux-ia64 has a theory?

.q/ output from the runs below is available on:
http://gsyprf3.external.hp.com/~grundler/openib-perf-2006/rx2600-r4929/.q

The "insteresting" output files from the last q-syscollect run:
	netperf-pid5693-cpu0.info#0
	q-syscollect-pid5691-cpu0.info#0
	unknown-cpu0.info#2


q-view output for last run of netperf/SDP is:
Command: /usr/local/bin/netperf -p 12866 -l 60 -H 10.0.0.30 -t TCP_RR -T 0 0 -c -C -- -r 1 1 -s 0 -S 0
Flat profile of CPU_CYCLES in netperf-pid5693-cpu0.hist#0:
 Each histogram sample counts as 1.00034m seconds
 % time      self     cumul     calls self/call  tot/call name
  27.18      1.52      1.52     21.8M     69.9n     69.9n _spin_unlock_irqrestore<kernel>
  16.08      0.90      2.42     1.18M      761n      846n schedule<kernel>
   6.24      0.35      2.77     1.29M      271n     2.56u sdp_inet_recv<kernel>
   4.33      0.24      3.01     2.59M     93.6n     93.6n __kernel_syscall_via_break<kernel>
   3.90      0.22      3.23     1.18M      185n      342n sdp_send_buff_post<kernel>
   3.51      0.20      3.43     1.24M      158n      933n sdp_inet_send<kernel>
   2.70      0.15      3.58     2.48M     60.8n     60.8n kmem_cache_free<kernel>
   2.11      0.12      3.69     4.82M     24.5n     24.5n kmem_cache_alloc<kernel>
   1.93      0.11      3.80     1.20M     90.1n      358n sdp_recv_flush<kernel>
   1.79      0.10      3.90     2.53M     39.5n     39.5n fget<kernel>
   1.75      0.10      4.00     1.22M     80.2n     2.95u sys_recv<kernel>
   1.65      0.09      4.09     1.22M     75.4n      414n sdp_send_data_queue_test<kernel>
   1.59      0.09      4.18     1.25M     71.3n     1.16u sys_send<kernel>
   1.54      0.09      4.27         -         -         - send_tcp_rr
   1.41      0.08      4.35     2.33M     33.9n     33.9n sdp_buff_q_put_tail<kernel>
   1.22      0.07      4.41     21.7M     3.14n     3.14n _spin_lock_irqsave<kernel>
   1.09      0.06      4.48     1.25M     48.7n     48.7n __divsi3<kernel>
   1.06      0.06      4.53     1.23M     48.1n     2.86u sys_recvfrom<kernel>
   1.02      0.06      4.59     2.29M     24.9n     24.9n sba_map_single<kernel>
   1.02      0.06      4.65     2.49M     22.9n     63.0n sockfd_lookup<kernel>
   0.98      0.06      4.70         -         -         - sdp_exit<kernel>
   0.98      0.06      4.76     1.26M     43.7n      967n sock_sendmsg<kernel>
   0.97      0.05      4.81     2.38M     22.7n     72.3n sdp_buff_pool_get<kernel>
   0.95      0.05      4.87     2.50M     21.2n     21.2n fput<kernel>
   0.91      0.05      4.92     1.23M     41.4n     2.72u sock_recvmsg<kernel>
   0.89      0.05      4.97     1.19M     42.1n     62.9n memcpy_toiovec<kernel>
   0.88      0.05      5.02     2.50M     19.6n     19.6n __copy_user<kernel>
   0.86      0.05      5.06     1.21M     39.8n      868n schedule_timeout<kernel>
   0.82      0.05      5.11     1.29M     35.7n      128n send
   0.79      0.04      5.15     1.25M     35.1n     35.1n sched_clock<kernel>
   0.64      0.04      5.19     1.29M     27.8n      123n recv
   0.59      0.03      5.22     1.23M     26.9n     26.9n __udivdi3<kernel>
   0.59      0.03      5.26     1.19M     27.8n     99.1n mthca_tavor_post_send<kernel>
   ....
                     

q-view output for the q-syscollect process:
Command: q-syscollect /usr/local/bin/netperf -p 12866 -l 60 -H 10.0.0.30 -t TCP_
RR -T 0,0 -c -C -- -r 1,1 -s 0 -S 0
Flat profile of CPU_CYCLES in q-syscollect-pid5691-cpu0.hist#0:
 Each histogram sample counts as 1.00034m seconds
 % time      self     cumul     calls self/call  tot/call name
  0.00      0.00      0.00       162      0.00      0.00 _spin_lock_irqsave<kernel>
  0.00      0.00      0.00       149      0.00      0.00 _spin_unlock_irqrestore <kernel>
  0.00      0.00      0.00       115      0.00      0.00 lock_timer_base<kernel>
  0.00      0.00      0.00       102      0.00      0.00 schedule<kernel>
  0.00      0.00      0.00      41.0      0.00      0.00 kfree<kernel>
  ...

Only notable thing here is it calls "schedule" and triggers
an additional ~160 interrupts (my guess).


unknown-cpu0.info#2 is probably interesting too:

Flat profile of CPU_CYCLES in unknown-cpu0.hist#2:
 Each histogram sample counts as 1.00034m seconds
 % time      self     cumul     calls self/call  tot/call name
  91.59     53.37     53.37      931k     57.3u     57.3u default_idle
   4.53      2.64     56.00     10.8M      244n      244n _spin_unlock_irqrestore
   1.78      1.04     57.04     1.27M      815n      885n schedule
   0.75      0.43     57.48     1.38M      315n     2.30u mthca_eq_int
   0.49      0.28     57.76     1.38M      206n     2.57u handle_IRQ_event
   0.19      0.11     57.87         -         -         - cpu_idle
   0.14      0.08     57.96     1.35M     62.1n     2.41u mthca_tavor_msi_x_interrupt
   0.10      0.06     58.02     1.32M     45.4n     2.07u mthca_cq_completion
   ...


thanks,
grant
