From: "Luck, Tony" <tony.luck@intel.com>
Date: Wed, 14 Nov 2007 22:19:15 +0000
Subject: RE: [PATCH] XPC heartbeat timer function must run on CPU 0
Message-Id: <617E1C2C70743745A92448908E030B2A02F1929C@scsmsx411.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
In-Reply-To: <20071107135306.99AAF11C415@aqua.americas.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> Wouldn't that cpu appear to the new OS instance as cpu0?  If so, then
>> it should not be an issue.
>
> No, I don't believe that it does.
> I can try and test this theory if it helps.
> Perhaps my mind is corrupted by x86 thoughts.

We are talking about logical cpu0 here.  Surely the new instance
must call whatever cpu it is running on first "0".  E.g. I could
have used kexec to switch to a UP kernel that only supports cpu0.

-Tony
