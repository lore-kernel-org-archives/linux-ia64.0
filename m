From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
Date: Mon, 19 Jun 2000 20:50:07 +0000
Subject: [Linux-ia64] [Fwd: IA64 version of 2.4.0-test1 has compile errors/config errors]
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------238C1E9C638E85965A40B4E8"
Message-Id: <marc-linux-ia64-105590678205166@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590678205165@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590678205165@msgid-missing>
To: linux-ia64@vger.kernel.org

This is a multi-part message in MIME format.
--------------238C1E9C638E85965A40B4E8
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

 
--------------238C1E9C638E85965A40B4E8
Content-Type: message/rfc822
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

X-Mozilla-Status2: 00000000
Message-ID: <394E69D0.E867BCBF@timpanogas.com>
Date: Mon, 19 Jun 2000 12:43:28 -0600
From: "Jeff V. Merkey" <jmerkey@timpanogas.com>
Organization: TRG, Inc.
X-Mailer: Mozilla 4.7 [en] (WinNT; I)
X-Accept-Language: en
MIME-Version: 1.0
To: linux-kernel@vger.rutgers.edu
Subject: IA64 version of 2.4.0-test1 has compile errors/config errors
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


The IA64 build of 2.4.0-test1 reports type mismatch errors for strlen()
and memset() with the latest build of linux-2.4.0-test1 at
www.kernel.org when you build the kernel under the NUE environment with
the GCC IA64 compiler/linker.  The compile error indicates a conflict
with built in functions with the same name.   

The .config file is also has sone issues.  When you follow the
instructions that come with SKI and NUE for IA64, they instruct you to
copy the kernel.config file that comes with the IA64 SKI simulator file
system over the default .config in the /linux main build directory. 
After running "make config" or "make oldconfig", several config options
get deleted from .config such as CONFIG_SIMETH=y, CONFIG_SIM_SERIAL=y,
and CONFIG_SIM_SCSI=y and have to be "hacked in" manually or the target
vmlinux file does not get built properly and will not load correctly
with SKI.  

Also, IA32 emulation support is listed in .config as "experimental", but
seems to work ok when enabled.  The lack of loadable module support also
seems troublesome.  I am assuming modutils have not been modified to
support IA64?

:-)

Jeff

--------------238C1E9C638E85965A40B4E8--



