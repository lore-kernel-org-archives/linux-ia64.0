From: Matthew Wilcox <willy@debian.org>
Date: Mon, 08 Dec 2003 16:01:24 +0000
Subject: gcc builtin memcpy is bogus?
Message-Id: <marc-linux-ia64-107090003129207@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org


This is a fun one ... I don't know what to blame for this.

struct rfd {
        u16 status;
        u16 command;
        u32 link;
        u32 rbd;
        u16 actual_size;
        u16 size;
};

static void e100_rx_rfa_add_tail(struct nic *nic, struct rx_list *curr)
{
        struct rfd *rfd = (struct rfd *)curr->skb->data;
        
        memcpy(rfd, &nic->blank_rfd, sizeof(struct rfd));
}

I'm using gcc (GCC) 3.3.2 (Debian) for this.

The kernel doesn't use -fno-builtin or -fno-builtin-memcpy so it attempts
to optimise this by doing 4-byte loads and stores.  Problem is, the
destination is misaligned (deliberately), so the kernel emits unaligned
messages.  Adding -fno-builtin to the command line turns this back into
a call to memcpy.

So how should this be fixed?

 - Improve gcc's builtin memcpy to work on non-aligned structs (unlikely)?
 - Somehow tag the pointer or the struct that it's unaligned?
 - Compile with -fno-builtin-memcpy (and probably a few others too)?

Other suggestions?

-- 
"Next the statesmen will invent cheap lies, putting the blame upon 
the nation that is attacked, and every man will be glad of those
conscience-soothing falsities, and will diligently study them, and refuse
to examine any refutations of them; and thus he will by and by convince 
himself that the war is just, and will thank God for the better sleep 
he enjoys after this process of grotesque self-deception." -- Mark Twain
