From: Hidetoshi Seto <seto.hidetoshi@jp.fujitsu.com>
Date: Fri, 04 Mar 2005 12:40:58 +0000
Subject: Re: [PATCH/RFC] I/O-check interface for driver's error handling
Message-Id: <4228575A.8070708@jp.fujitsu.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <422428EC.3090905@jp.fujitsu.com>
In-Reply-To: <422428EC.3090905@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Linux Kernel list <linux-kernel@vger.kernel.org>, linux-pci@atrey.karlin.mff.cuni.cz, linux-ia64@vger.kernel.org
Cc: Linus Torvalds <torvalds@osdl.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linas Vepstas <linas@austin.ibm.com>, "Luck, Tony" <tony.luck@intel.com>

Thanks for all comments!

OK, I'd like to sort our situation:

################

$ Here are 2 features:
   - iochk_clear/read() interface for error "detection"
       by Seto ... me :-)
   - callback, thread, and event notification for error "recovery"
       by Linas ... expert in PPC64

$ What will "detection" interface provides?
   - allow drivers to get error information
      - device/bus was isolated/going-reset/re-enabled/etc.
      - error status which hardware and PCI subsystem provides
   - allow drivers to do "simple retry" easily
      - major soft errors(*1) would be recovered by a simple retry
      - in cases that device/bus was re-enabled but a retry is required

$ What will "recovery" infrastructure provides?
   - allow drivers to help OS's recovery
      - usually OS cannot re-enable affected devices by itself
   - allow drivers to respond asynchronous error event
      - allow drivers to implement "device specific recovery"

$ Difference of stance
   - "detection"
      - Assume that the number of soft error is far more than that of
        hard error. (PCI-Express has ECC, but traditional PCI does not.)
      - Assume that it isn't too late that attempt of device isolation
        and/or recovery comes after a simple retry(*2), and that a retry
        would be required even if the recovery had go well.
      - It isn't matter whether device isolation is actually possible or
        not for the arch. The fundamental intention of this interface is
        prevent user applications from data pollution.
      - Currently DMA and asynchronous I/O is not target.
   - "recovery"
      - (I'd appreciate it if Linas could fill here by his suitable words.)
      - (Maybe,) it is based on assuming that erroneous device should be
        isolated immediately irrespective of type of the error.
      - (I guess that) once a device was isolated, it become harder to
        re-enable it. It seems like a kind of hotplug feature.
      - Currently there are few platform which can isolate devices and
        attempt to recover from the I/O error.

$ How to use
   - "detection" ... easy.
      - clip I/Os by iochk_clear() and iochk_read()
      - if iochk_read() returns non-0, retry once and/or notify the error
        to user application.
   - "recovery" ... rather hard.
      - (I'd appreciate it if Linas could fill here by his suitable words.)
      - write callback function for each event(*3)

-----

*1:
   Traditionally, there are 2 types of error:
    - soft error:
        data was broken (ex. due to low voltage, natural radiation etc.)
        temporary error
    - hard error:
        device or bus was physically broken (i.e. uncorrectable)
        permanent error

*2:
   it's difficult to distinguish hard errors from soft errors, without
   any retry.

*3:
   Linas, how many stages/events would you prefer to be there? is 3 enough?

   ex. IMHO:

   IOERR_DETECTED
     - An error was detected, so error logging or device isolation would be
       major request. On PPC64, isolation would be already done by hardware.
   IOERR_PREPARE_RECOVERY
     - Require preparation before attempting error recovery by OS.
   IOERR_DO_RECOVERY
     - Require device specific recovery and result of the recovery.
       OS will gather all results and will decide recovered or not.
   IOERR_RECOVERED
     - OS recovery was succeeded.
   IOERR_DEAD
     - OS recovery was failed.

   And as Ben said and as you already proposed, I also think only one callback
   is enough and better, like:
     int pci_emergency_callback(pci_dev *dev, err_event event, void *extra)

   It allows us to add new event if desired.

################

Thanks,
H.Seto

