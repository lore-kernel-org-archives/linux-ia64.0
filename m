From: "Luck, Tony" <tony.luck@intel.com>
Date: Mon, 21 Nov 2005 22:11:28 +0000
Subject: RE: Fix asm constraint in put_user
Message-Id: <B8E391BBE9FE384DAA4C5C003888BE6F0504DD49@scsmsx401.amr.corp.intel.com>
List-Id: <linux-ia64.vger.kernel.org>
References: <je7jb2nigc.fsf@sykes.suse.de>
In-Reply-To: <je7jb2nigc.fsf@sykes.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>> You could use the "S" constraint here.  This isn't used anywhere in
>> gcc.  This exists solely for use by asms that need a non-postinc MEM.
>
>Alas, it does not work:

So should I go with the original patch using "r"?  I agree with Andreas'
assessment that it doesn't matter that we didn't tell gcc that memory
was being changed, since the memory that gets changed isn't in a space
that gcc knows about.

Or are there any more letters of the alphabet to try :-)

-Tony
