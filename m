From: David Mosberger <davidm@napali.hpl.hp.com>
Date: Wed, 14 May 2003 02:21:50 +0000
Subject: Re: [Linux-ia64] Dump driver module
Message-Id: <marc-linux-ia64-105590723705771@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
References: <marc-linux-ia64-105590723705751@msgid-missing>
In-Reply-To: <marc-linux-ia64-105590723705751@msgid-missing>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

>>>>> On Wed, 14 May 2003 12:14:21 +1000, Martin Pool <mbp@samba.org> said:

  Martin> On 13 May 2003, Bruno Vidal <bruno_vidal@hp.com> wrote:
  >> Hi
  >> Sorry, but LKCD is really not usefull because it use the buffer
  >> to write on the device. So it just hang in case of data page fault for
  >> example (because interuption are masked), LKCD is also not working in case
  >> of buffer corruption, disk driver pb, etc.... so LKCD is not usable in
  >> lot's of case (and it happen really often to have data page fault).

  Martin> There is also the netconsole/netdump system.  This is supposed to rely
  Martin> on only a very minimal network driver.  As you say, writing to disk
  Martin> when kernel memory may have been corrupted is a risky business, not
  Martin> only because you might hang but also because you might write over the
  Martin> wrong region.  netdump doesn't do any disk IO for that reason.  I seem
  Martin> to recall that Linus liked this property.

  Martin> Of course it's only useful if the machine is on a network where there
  Martin> is another machine to catch the data, but I would expect that to be
  Martin> the case for most ia64 machines.

  Martin> http://www.redhat.com/support/wpapers/redhat/netdump/

It strikes me that for a really reliable crash-dump, you'd want to
read _all_ the bits needed to do the dumping from ROM.  Assuming you
have a (minimal) disk driver/network driver written in EFI byte code,
all you'd need is the EFI byte-code interpreter which hopefully would
fit in a fixed (and reasonable) amount of space.  Hence you could
reserve some memory for this purpose and on a crash, load the
byte-code interpreter from ROM and get going that way.

	--david

