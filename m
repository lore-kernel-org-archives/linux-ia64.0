From: Grant Grundler <grundler@cup.hp.com>
Date: Tue, 27 Aug 2002 18:00:25 +0000
Subject: [Linux-ia64] PATCH 2.4.19 ppp_generic.c
Message-Id: <marc-linux-ia64-105590701905985@msgid-missing>
List-Id: <linux-ia64.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: linux-ia64@vger.kernel.org

ppp_generic.c won't build as a module.
Using "outl" as a label is a bad idea.
Also fixed one warning - might pick a different value
for the "ret" value though.

grant

Index: drivers/net/ppp_generic.c
=================================RCS file: /var/cvs/linux/drivers/net/ppp_generic.c,v
retrieving revision 1.4
diff -u -p -r1.4 ppp_generic.c
--- drivers/net/ppp_generic.c	27 Aug 2002 15:21:04 -0000	1.4
+++ drivers/net/ppp_generic.c	27 Aug 2002 17:54:56 -0000
@@ -378,7 +378,7 @@ static ssize_t ppp_read(struct file *fil
 {
 	struct ppp_file *pf = file->private_data;
 	DECLARE_WAITQUEUE(wait, current);
-	ssize_t ret;
+	ssize_t ret = -1;
 	struct sk_buff *skb = 0;
 
 	if (pf = 0)
@@ -404,19 +404,19 @@ static ssize_t ppp_read(struct file *fil
 	remove_wait_queue(&pf->rwait, &wait);
 
 	if (skb = 0)
-		goto out;
+		goto err1;
 
 	ret = -EOVERFLOW;
 	if (skb->len > count)
-		goto outf;
+		goto err2;
 	ret = -EFAULT;
 	if (copy_to_user(buf, skb->data, skb->len))
-		goto outf;
+		goto err2;
 	ret = skb->len;
 
- outf:
+ err2:
 	kfree_skb(skb);
- out:
+ err1:
 	return ret;
 }
 
@@ -432,12 +432,12 @@ static ssize_t ppp_write(struct file *fi
 	ret = -ENOMEM;
 	skb = alloc_skb(count + pf->hdrlen, GFP_KERNEL);
 	if (skb = 0)
-		goto out;
+		goto err1;
 	skb_reserve(skb, pf->hdrlen);
 	ret = -EFAULT;
 	if (copy_from_user(skb_put(skb, count), buf, count)) {
 		kfree_skb(skb);
-		goto out;
+		goto err1;
 	}
 
 	skb_queue_tail(&pf->xq, skb);
@@ -453,7 +453,7 @@ static ssize_t ppp_write(struct file *fi
 
 	ret = count;
 
- out:
+ err1:
 	return ret;
 }
 
@@ -806,7 +806,7 @@ ppp_start_xmit(struct sk_buff *skb, stru
 
 	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
-		goto outf;
+		goto err1;
 
 	/* Drop, accept or reject the packet */
 	switch (ppp->npmode[npi]) {
@@ -815,10 +815,10 @@ ppp_start_xmit(struct sk_buff *skb, stru
 	case NPMODE_QUEUE:
 		/* it would be nice to have a way to tell the network
 		   system to queue this one up for later. */
-		goto outf;
+		goto err1;
 	case NPMODE_DROP:
 	case NPMODE_ERROR:
-		goto outf;
+		goto err1;
 	}
 
 	/* Put the 2-byte PPP protocol number on the front,
@@ -828,7 +828,7 @@ ppp_start_xmit(struct sk_buff *skb, stru
 
 		ns = alloc_skb(skb->len + dev->hard_header_len, GFP_ATOMIC);
 		if (ns = 0)
-			goto outf;
+			goto err1;
 		skb_reserve(ns, dev->hard_header_len);
 		memcpy(skb_put(ns, skb->len), skb->data, skb->len);
 		kfree_skb(skb);
@@ -844,7 +844,7 @@ ppp_start_xmit(struct sk_buff *skb, stru
 	ppp_xmit_process(ppp);
 	return 0;
 
- outf:
+err1:
 	kfree_skb(skb);
 	++ppp->stats.tx_dropped;
 	return 0;
@@ -1945,11 +1945,11 @@ ppp_set_compress(struct ppp *ppp, unsign
 	if (copy_from_user(&data, (void *) arg, sizeof(data))
 	    || (data.length <= CCP_MAX_OPTION_LENGTH
 		&& copy_from_user(ccp_option, data.ptr, data.length)))
-		goto out;
+		goto err1;
 	err = -EINVAL;
 	if (data.length > CCP_MAX_OPTION_LENGTH
 	    || ccp_option[1] < 2 || ccp_option[1] > data.length)
-		goto out;
+		goto err1;
 
 	cp = find_compressor(ccp_option[0]);
 #ifdef CONFIG_KMOD
@@ -1960,7 +1960,7 @@ ppp_set_compress(struct ppp *ppp, unsign
 	}
 #endif /* CONFIG_KMOD */
 	if (cp = 0)
-		goto out;
+		goto err1;
 	/*
 	 * XXX race: the compressor module could get unloaded between
 	 * here and when we do the comp_alloc or decomp_alloc call below.
@@ -1998,7 +1998,7 @@ ppp_set_compress(struct ppp *ppp, unsign
 		}
 	}
 
- out:
+err1:
 	return err;
 }
 
@@ -2144,15 +2144,15 @@ ppp_register_compressor(struct compresso
 	spin_lock(&compressor_list_lock);
 	ret = -EEXIST;
 	if (find_comp_entry(cp->compress_proto) != 0)
-		goto out;
+		goto err1;
 	ret = -ENOMEM;
 	ce = kmalloc(sizeof(struct compressor_entry), GFP_ATOMIC);
 	if (ce = 0)
-		goto out;
+		goto err1;
 	ret = 0;
 	ce->comp = cp;
 	list_add(&ce->list, &compressor_list);
- out:
+ err1:
 	spin_unlock(&compressor_list_lock);
 	return ret;
 }
@@ -2431,11 +2431,12 @@ ppp_connect_channel(struct channel *pch,
 	down(&all_ppp_sem);
 	ppp = ppp_find_unit(unit);
 	if (ppp = 0)
-		goto out;
+		goto err1;
+
 	write_lock_bh(&pch->upl);
 	ret = -EINVAL;
 	if (pch->ppp != 0)
-		goto outl;
+		goto err2;
 
 	ppp_lock(ppp);
 	if (pch->file.hdrlen > ppp->file.hdrlen)
@@ -2450,9 +2451,9 @@ ppp_connect_channel(struct channel *pch,
 	ppp_unlock(ppp);
 	ret = 0;
 
- outl:
+ err2:
 	write_unlock_bh(&pch->upl);
- out:
+ err1:
 	up(&all_ppp_sem);
 	return ret;
 }

