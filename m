From: Steinar Traedal-Henden <steinar@cc.uit.no>
Date: Mon, 17 Mar 2003 20:32:13 +0000
Subject: Re: [Linux-ia64] rx2600 HW-error only when running 2.4.20
Message-Id: <marc-linux-ia64-105590709806145@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709806136@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709806136@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

Hi Alex,

So, its nothing to worry about, but how can I configure the kernel so that the
error message dissapear? It really fills up the syslog..

here is the output of lspci and errdump: (hope you can help)


[compute-1-0]# lspci -s 0x80: -vvv
80:1e.0 Host bridge: Hewlett-Packard Company zx1 Local Bus Adapter (rev 32)
        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr+ Stepping- SERR+ FastB2B-
        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=medium >TAbort- <TAbort- <MAbort- >SERR- <PERR-
        Latency: 64, cache line size 20
        Region 0: Memory at 00000000fed28000 (32-bit, non-prefetchable) [size=8K]
        Capabilities: [a0] PCI-X non-bridge device.
                Command: DPERE+ ERO- RBC=0 OST=0
                Status: Bus=0 Dev=0 Func=0 64bit- 133MHz- SCD- USC-, DC=simple, DMMRBC=0, DMOST=0, DMCRS=0, RSCEM-



Shell> errdump cpe
**** CPE Error Log Dump ****

Firmware Revision: fwbtr_main_view.01.44-0
Architected SAL Record ID  0x0000000000000000
Time this log was recorded: 03/17/2003 at 11:19:30


**** zx1 IOC Registers ****
  iocErrorValid                 0x0000000000000000


**** PCI Component Registers ****
  pciCompErrorValid             0x0000000000000000


**** PCI Bus Registers ****
  pciBusErrorValid              0x0000000000000001

  ---- PCI Bus ----
  validation_bits               0x000000000000048f
  error_status                  0x00000000004a1700
  error_type                    0x            0000
  bus_id                        0x            0080
  bus_addr                      0x0000000000000000
  bus_data                      0x0000000000000000
  bus_cmd                       0x0000000000000000
  bus_requestor_id              0x0000000000000000
  bus_responder_id              0x00000000fed28000
  bus_target_id                 0x0000000000000000
  bus_oem_id[0]                 0x000000000000122e
  bus_oem_id[1]                 0x0000000000000000
  cellNum                       0x        00000000
  sbaNum                        0x            0000
  ropeNum                       0x            0004
  .... Mercury LBA ....
  error_status 0x688            0x0000080100000801
  master_id_log 0x0690          0x0000000000000010
  inbound_err_add 0x0290        0x0000000000000000
  inbound_err_attrib 0x0298     0x0000000000000000
  completion_msg_log 0x02A0     0x0000000000000000
  outbound_err_address 0x0070   0x0000000000000000
  error_config 0x0680           0x0000000000001d50
  status_info_cntrl 0x0108      0x0000000000000040
  function_id 0x0000            0x02b00146122e103c
  capabilities_list 0x0060      0x0f00023700200002
  agp_command 0x0068            0x0000000000000000
  pcix_capabilities 0x00A0      0x0013ff0000010007
  olr_control 0x0600            0x0002371d00032403
  clock_control 0x0618          0x0000000000000038
  bus_mode 0x0620               0xa1a974ae2f3504c0



regards
Steinar



On Mon, 17 Mar 2003, Alex Williamson wrote:

> Steinar Traedal-Henden wrote:
> >
> > Hi,
> >
> > I get the following HW error on a HP rx2600 when I run my own compiled
> > 2.4.20 kernel.
> >
> > Mar 17 04:13:35 compute-1-0 kernel: +BEGIN HARDWARE ERROR STATE AT CPE
> > Mar 17 04:13:35 compute-1-0 kernel: +Err Record ID: 2833    SAL Rev:  0.02
> > Mar 17 04:13:35 compute-1-0 kernel: +Time: 03/17/2003 04:19:49    Severity 2
> > Mar 17 04:13:35 compute-1-0 kernel: +Platform PCI Bus Error Info Section
> > Mar 17 04:13:35 compute-1-0 kernel: + PCI Bus Error Detail:  Error Status: 0x4a1700 Error Type: 0x0 Bus ID: 0x80 Bus Address: 0x0 Responder ID: 0xfed28000+END HARDWARE ERROR STATE AT CPE
>
>    You're getting a CPE (Corrected Platform Error) record.  Polling
> for CPEs was added in 2.4.20, so it's not surprising you didn't see
> them before.  The good news is that the error is corrected, this is
> just the system telling you about it.  You should probably try to
> figure out what the problem is though in case it leads to uncorrectable
> problems that will MCA your box.  Most of the error record is documented
> in the SAL spec.  Here's what we can determine:
>
> Error Status: 0x4a1700
>
>  - bit8-15 = Error Type 0x17 = 23 = ERR_PROTOCOL (Detection of a protocol error)
>  - bit 17 = Control: Error was detected on the control signals or in
>             the control portion of the transaction
>  - bit 19 = Responder: Error was detected by the responder of the transaction
>  - bit 22 = Overflow
>
> Error Type: 0x0 = Unknown or OEM System Specific Error
>
> What do you have in the slot corresponding to bus 0x80?  An lspci -vvv
> might be helpful.  If you go back to an EFI Shell and run 'errdump cpe'
> that might provide us with more information about what's happening.
> Thanks,
>
> 	Alex
>
> --
> Alex Williamson                             HP Linux & Open Source Lab
>
> _______________________________________________
> Linux-IA64 mailing list
> Linux-IA64@linuxia64.org
> http://lists.linuxia64.org/lists/listinfo/linux-ia64
>


