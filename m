From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Sat, 31 May 2003 01:34:24 +0000
Subject: Re: [Linux-ia64] [PATCH] MCA recovery for TLB faults for 2.4
Message-Id: <marc-linux-ia64-105590723706101@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723706058@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723706058@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 28 May 2003 13:35:53 -0700, "Luck, Tony" <tony.luck@intel.com> said:

  Tony> The underlying algorithm is to save information about what
  Tony> each of the ITR/DTR registers is mapping, then at MCA time we
  Tony> can purge the whole TLB (TC and TR) and reload the TR
  Tony> registers before jumping to virtual mode.

Are you just blindly trusting that memory is still correct after
getting a TLB error report?  Wouldn't you want to have a checksum to
validate that the list of saved translations is probably correct.
Otherwise, it seems to me the TLB purge could make a bad situation
worse.

	--david

