From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 28 Sep 2009 23:01:50 +0000
Subject: RE: [git pull] ia64 changes
Message-Id: <57C9024A16AD2D4C97DC78E552063EA3E2EA361E@orsmsx505.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
In-Reply-To: <1FE6DD409037234FAB833C420AA843EC0122AEB1@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> 	ticket = ia64_fetchadd(1, p, acq);
>> 
>> 	if (!(((ticket >> TICKET_SHIFT) ^ ticket) & ((1L << TICKET_BITS) - 1)))
>> 		return;
>
> I think the above is wrong.
>
> Doesn't 'fetchadd' return the _old_ value?


Yes, It does return the old value ... but that it what we want.  When
we tear the ticket from the machine on the Deli counter, our ticket
number is the OLD value.  The updated value becomes the ticket number
for the next person to come along.

I.e. we start the lock with value 0x00000000, so the ticket showing is
0, and the now serving number is 0.  We fetchadd a ticket and the lock
goes to 0x00000001 ... and we own the lock because the ticket we pulled
matches the now-serving number.  When we are done we bumb the now-serving
value, so the lock goes to 0x00020001 and the lock is free again.

Did I do this differently from x86?

-Tony
