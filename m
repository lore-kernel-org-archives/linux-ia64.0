From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Oct 2002 17:12:20 +0000
Subject: RE: [Linux-ia64] quick ia64 patch for 2.5.44 (UP only)
Message-Id: <marc-linux-ia64-105590709805278@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590709805243@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590709805243@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

> Keyboard cannot be used on my Bigsur since 2.5.3? also.
> I've heard that there was a same problem at early 2.4.

I don't know if it was the the same problem, but the symptoms
and the workaround are the same.  Through most of the mid-teens
2.4 kernel would come up on BigSur with the keyboard non-functional.
Unplugging the keyboard, and replugging it would fix it. I
forget the release when this stopped happening, but 2.4.18 and
2.4.19 definitely don't have this problem.

2.5.39 is doing the same thing (but now I have a Belkin KVM switch
in between the keyboard and the machine, just selecting a different
machine, and then selecting back to the BigSur corrects the problem).

-Tony

