From: Andreas Dilger <adilger@clusterfs.com>
Date: Wed, 07 Jul 2004 04:35:04 +0000
Subject: Re: [PATCH] Pushing file size limits to 4TB on ext3
Message-Id: <20040707043504.GN3002@schnapps.adilger.int>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="YPJ8CVbwFUtL7OFW"
List-Id: <linux-ia64.vger.kernel.org>
References: <33BC33A9E76474479B76AD0DE8A169728DAF@exch-ntd.nec.noida.hcltech.com>
In-Reply-To: <33BC33A9E76474479B76AD0DE8A169728DAF@exch-ntd.nec.noida.hcltech.com>
To: Goldwyn Rodrigues <Goldwynr@noida.hcltech.com>
Cc: linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org, jbglaw@liug-owl.de


--YPJ8CVbwFUtL7OFW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Jul 07, 2004  09:18 +0530, Goldwyn Rodrigues wrote:
> Andreas suggested fields which deal with fragments could be used as they
> are not used by anyone. However, I did not get any response from anyone
> on whether those fields are being used. I did find the reference in the
> code, which has been used only for reading and writing inodes to disk.
> However, in order to change it to another 32-bit variable,
> #define i_blocks_high could be "redefined".

Since the addition of an RO_COMPAT field requires that e2fsprogs be fixed
to understand this change (and to validate that the i_blocks_high value
is sane, relative to the i_size) there is no harm in using the i_frag and
i_fsize fields.  If you look at current e2fsck code, it _requires_ that
i_frag and i_fsize are zero so they could not possibly be used for anything.

Having a 16-bit field for the i_blocks_high is enough and is guaranteed not
to conflict with HURD.

> @@ -2651,7 +2661,29 @@ static int ext3_do_update_inode(handle_t
>  	} else {
>  		raw_inode->i_size_high =3D
>  			cpu_to_le32(ei->i_disksize >> 32);
> -		if (ei->i_disksize > 0x7fffffffULL) {
> +	=09
> +		if (ei->i_disksize > 0x1ffffffffffULL) {
> +			struct super_block *sb =3D inode->i_sb;
> +			if (!EXT3_HAS_RO_COMPAT_FEATURE(sb, EXT3_FEATURE_RO_COMPAT_4TB_FILE) =
|| EXT3_SB(sb)->s_es->s_rev_level =3D=3D cpu_to_le32(EXT3_GOOD_OLD_REV)) {

1) Please wrap lines at 80 characters
2) This check should actually be done at i_blocks > 0xffffffffULL instead of
   being related to the file size.  It should be possible to have large
   sparse files that do not cause this feature flag to be invoked.
3) The feature should be called something like "RO_COMPAT_MANY_BLOCKS" or
   similar, since it isn't necessarily related to 4TB file sizes.
4) It is better to keep this feature independent from RO_COMPAT_LARGE_FILE,
   since that is related to i_size.  Just do two separate tests here.

> @@ -1172,8 +1172,8 @@ static loff_t ext3_max_size(int bits)
>  	res +=3D 1LL << (2*(bits-2));
>  	res +=3D 1LL << (3*(bits-2));
>  	res <<=3D bits;
> -	if (res > (512LL << 32) - (1 << bits))
> -		res =3D (512LL << 32) - (1 << bits);
> +        if (res > (1024LL << 32) - (1 << bits))
> +                res =3D (1024LL << 32) - (1 << bits);

This doesn't make sense.  The earlier checks already provide the correct
limits based on indirect blocks (although it would be good to independently
verify that).  With your patch we are not limited to 4TB at all (think larg=
er
block sizes) so there is no reason to add this extra limit.

> +config EXT3_LARGE_FILE_SUPPORT
> +	bool "Large File (>2TB) Support (EXPERIMENTAL)"
> +	depends on EXT3_FS
> +	depends on LBD
> +	default n
> +	help
> +	  Ext3 filesystem currently has a limit of 2TB. This experimental
> +	  release extends this limit to 8TB by using the reserved fields
                                        ^^^ 4TB (or more with blocksize
					         larger than 4kB on 64-bit
						 systems)
Cheers, Andreas
--
Andreas Dilger
http://sourceforge.net/projects/ext2resize/
http://members.shaw.ca/adilger/             http://members.shaw.ca/golinux/


--YPJ8CVbwFUtL7OFW
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.3 (GNU/Linux)

iD8DBQFA6314pIg59Q01vtYRAmezAKCdRwEOf4HeQArDcyHJgVU2vnq9vwCeJBoA
nyqTH1gQC2vRyFPNWn8L6As=
=kEZZ
-----END PGP SIGNATURE-----

--YPJ8CVbwFUtL7OFW--
