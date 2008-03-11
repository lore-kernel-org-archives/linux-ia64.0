From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 11 Mar 2008 17:48:12 +0000
Subject: Re: [PATCH, RFC] Create 'slot' sysfs attribute in/sys/devices/system/cpu/cpuN/topology/
Message-Id: <20080311174812.GD21482@parisc-linux.org>
List-Id: <linux-ia64.vger.kernel.org>
References: <20080310222735.GA22619@ldl.fc.hp.com> <1FE6DD409037234FAB833C420AA843ECC8960D@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECC8960D@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Alex Chiang <achiang@hp.com>, lenb@kernel.org, linux-ia64@vger.kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Mar 11, 2008 at 10:31:43AM -0700, Luck, Tony wrote:
> Perhaps this next rant is beyond the scope of Linux architecture
> and more on overall systems useabilty.  It is just asking for
> trouble to print a message on the console telling the user to go
> pull out the board in "slot 2".  Do the slot numbers count from
> "0" or from "1"?  Are they numbered left-to-right or right-to-left?
> What if the rack is non-standard so the system was rotated 90
> degrees?  Now are they numbered top-to-bottom or bottom-to-top.

Some systems (particularly those designed for hotplug) have the numbers
silk-screened onto the case.  It's like PCI slots ... my beige-box
homebrew PCs don't have slot numbers written on them, but the machines I
have from HP are very clearly labelled with slot numbers beside each PCI
slot.

Admittedly, the flashing red LED is a better UI, but it's not
necessarily as confusing as you're painting it.

-- 
Intel are signing my paycheques ... these opinions are still mine
"Bill, look, we understand that you're interested in selling us this
operating system, but compare it to ours.  We can't possibly take such
a retrograde step."
