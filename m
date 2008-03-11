From: "Luck, Tony" <tony.luck@intel.com>
Date: Tue, 11 Mar 2008 17:31:43 +0000
Subject: RE: [PATCH, RFC] Create 'slot' sysfs attribute in/sys/devices/system/cpu/cpuN/topology/
Message-Id: <1FE6DD409037234FAB833C420AA843ECC8960D@orsmsx424.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com>
In-Reply-To: <20080310222735.GA22619@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alex Chiang <achiang@hp.com>, lenb@kernel.org
Cc: linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

> A while back, I submitted a patch to expose the value of the _SUN
> method for CPUs. On ia64, the "physical id" field in
> /proc/cpuinfo isn't sufficient for some legacy HP ia64 platforms,
> as they do not have a modern SAL or PAL.

Do these legacy systems with ancient SAL/PAL actually support
processor hot plug?

Perhaps this next rant is beyond the scope of Linux architecture
and more on overall systems useabilty.  It is just asking for
trouble to print a message on the console telling the user to go
pull out the board in "slot 2".  Do the slot numbers count from
"0" or from "1"?  Are they numbered left-to-right or right-to-left?
What if the rack is non-standard so the system was rotated 90
degrees?  Now are they numbered top-to-bottom or bottom-to-top.

Best idea is to have a (blinking) (red) light on the board and
instruct the operator to pull out the board with the fail-light
(but even then a red-green colour blind operator will still mess
it up for you and pull the wrong board :-)

-Tony
