From: "Seth, Rohit" <rohit.seth@intel.com>
Date: Thu, 14 Mar 2002 23:46:46 +0000
Subject: RE: [Linux-ia64] Kernel Shared Memory Max (shmmax)
Message-Id: <marc-linux-ia64-105590701905290@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590701905286@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590701905286@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

David,

If you need any preference of value for shmmax, then please go with 4G
(though there are utilities that expect size of shared memory segment to be
only int :) but that should be fixed seperately). Could you please make this
change in your next patch.

thanks,
rohit


-----Original Message-----
From: David Mosberger [mailto:davidm@napali.hpl.hp.com]
Sent: Thursday, March 14, 2002 3:32 PM
To: Seth, Rohit
Cc: 'dcooper@atcc.necsys.com'; ia64-list@redhat.com;
linux-ia64@linuxia64.org
Subject: RE: [Linux-ia64] Kernel Shared Memory Max (shmmax)


>>>>> On Thu, 14 Mar 2002 15:13:35 -0800, "Seth, Rohit"
<rohit.seth@intel.com> said:

  Rohit> Besides that, this low default
  Rohit> value of 32MB just adds overhead for big memory systems.  It
  Rohit> will be nice to change this default value to 2G at least for
  Rohit> IA-64 machines.

I agree; it always struck me as a curiosity from days long gone... ;-)

	--david

