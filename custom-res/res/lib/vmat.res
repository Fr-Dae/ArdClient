Haven Resource 1 src �  Mapping.java /* Preprocessed source code */
package haven.res.lib.vmat;

/* $use: lib/uspr */
import haven.*;
import java.util.*;
import haven.res.lib.uspr.*;

public abstract class Mapping extends Gob.ResAttr {
    public abstract Material mergemat(Material orig, int mid);

    public Rendered[] apply(Resource res) {
	Collection<Rendered> rl = new LinkedList<Rendered>();
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    String sid = mr.rdat.get("vm");
	    int mid = (sid == null)?-1:Integer.parseInt(sid);
	    if(mid >= 0) {
		rl.add(mergemat(mr.mat.get(), mid).apply(mr.m));
	    } else if(mr.mat != null) {
		rl.add(mr.mat.get().apply(mr.m));
	    }
	}
	return(rl.toArray(new Rendered[0]));
    }

    public final static Mapping empty = new Mapping() {
	    public Material mergemat(Material orig, int mid) {
		return(orig);
	    }
	};
}

/* >gattr: haven.res.lib.vmat.Materials */
src �  Materials.java /* Preprocessed source code */
package haven.res.lib.vmat;

/* $use: lib/uspr */
import haven.*;
import java.util.*;
import haven.res.lib.uspr.*;

public class Materials extends Mapping {
    public static final Map<Integer, Material> empty = Collections.<Integer, Material>emptyMap();
    public final Map<Integer, Material> mats;

    public static Map<Integer, Material> decode(Resource.Resolver rr, Message sdt) {
	Map<Integer, Material> ret = new IntMap<Material>();
	int idx = 0;
	while(!sdt.eom()) {
	    Indir<Resource> mres = rr.getres(sdt.uint16());
	    int mid = sdt.int8();
	    Material.Res mat;
	    if(mid >= 0)
		mat = mres.get().layer(Material.Res.class, mid);
	    else
		mat = mres.get().layer(Material.Res.class);
	    ret.put(idx++, mat.get());
	}
	return(ret);
    }

    public static Material stdmerge(Material orig, Material var) {
	haven.resutil.OverTex otex = null;
	for(GLState st : orig.states) {
	    if(st instanceof haven.resutil.OverTex) {
		otex = (haven.resutil.OverTex)st;
		break;
	    }
	}
	if(otex == null)
	    return(var);
	return(new Material(var, otex));
    }

    public Material mergemat(Material orig, int mid) {
	if(!mats.containsKey(mid))
	    return(orig);
	Material var = mats.get(mid);
	return(stdmerge(orig, var));
    }

    public Materials(Map<Integer, Material> mats) {
	this.mats = mats;
    }

    public Materials(Gob gob, Message dat) {
	this.mats = decode(gob.context(Resource.Resolver.class), dat);
    }
}

src Z  Wrapping.java /* Preprocessed source code */
package haven.res.lib.vmat;

/* $use: lib/uspr */
import haven.*;
import java.util.*;
import haven.res.lib.uspr.*;

public class Wrapping implements Rendered {
    public final Rendered r;
    public final GLState st;
    public final int mid;

    public Wrapping(Rendered r, GLState st, int mid) {
	this.r = r;
	this.st = st;
	this.mid = mid;
    }

    public void draw(GOut g) {}

    public boolean setup(RenderList rl) {
	rl.add(r, st);
	return(false);
    }

    public String toString() {
	return(String.format("#<vmat %s %s>", mid, st));
    }
}

src g  VarSprite.java /* Preprocessed source code */
package haven.res.lib.vmat;

/* $use: lib/uspr */
import haven.*;
import java.util.*;
import haven.res.lib.uspr.*;

public class VarSprite extends UnivSprite {
    private Gob.ResAttr.Cell<Mapping> aptr;
    private Mapping cmats;

    public VarSprite(Owner owner, Resource res, Message sdt) {
	super(owner, res, sdt);
	aptr = Gob.getrattr(owner, Mapping.class);
    }

    public Mapping mats() {
	return(((aptr != null) && (aptr.attr != null))?aptr.attr:Mapping.empty);
    }

    public Collection<Rendered> iparts(int mask) {
	Collection<Rendered> rl = new LinkedList<Rendered>();
	Mapping mats = mats();
	for(FastMesh.MeshRes mr : res.layers(FastMesh.MeshRes.class)) {
	    String sid = mr.rdat.get("vm");
	    int mid = (sid == null)?-1:Integer.parseInt(sid);
	    if(((mr.mat != null) || (mid >= 0)) && ((mr.id < 0) || (((1 << mr.id) & mask) != 0)))
		rl.add(new Wrapping(animmesh(mr.m), mats.mergemat(mr.mat.get(), mid), mid));
	}
	cmats = mats;
	return(rl);
    }

    public boolean tick(int idt) {
	if(mats() != cmats)
	    update();
	return(super.tick(idt));
    }
}
code �	  haven.res.lib.vmat.VarSprite ����   4 �
 " C D
 E F	 ! G	 ' H	  I J
  K
 ! L	 ! M O
 Q R S T U V U W	  X Y Z [ \
 ] ^	  _	  ` a	  b
 ! c
 d e
  f
  g S h	 ! i
 ! j
 " k l m aptr n ResAttr InnerClasses o Cell Lhaven/Gob$ResAttr$Cell; 	Signature 6Lhaven/Gob$ResAttr$Cell<Lhaven/res/lib/vmat/Mapping;>; cmats Lhaven/res/lib/vmat/Mapping; <init> q Owner 6(Lhaven/Sprite$Owner;Lhaven/Resource;Lhaven/Message;)V Code LineNumberTable mats ()Lhaven/res/lib/vmat/Mapping; StackMapTable D iparts (I)Ljava/util/Collection; r s O \ +(I)Ljava/util/Collection<Lhaven/Rendered;>; tick (I)Z 
SourceFile VarSprite.java . 1 haven/res/lib/vmat/Mapping t u v # ) w x y - java/util/LinkedList . z 4 5 { | } haven/FastMesh$MeshRes MeshRes ~  � r � � s � � � � � � vm � � � java/lang/String � � � � � � � haven/res/lib/vmat/Wrapping � � � � � � � � � . � � � , - � z ? @ haven/res/lib/vmat/VarSprite haven/res/lib/uspr/UnivSprite haven/Gob$ResAttr haven/Gob$ResAttr$Cell � haven/Sprite$Owner java/util/Collection java/util/Iterator 	haven/Gob getrattr =(Ljava/lang/Object;Ljava/lang/Class;)Lhaven/Gob$ResAttr$Cell; attr Lhaven/Gob$ResAttr; empty ()V res Lhaven/Resource; haven/FastMesh haven/Resource layers )(Ljava/lang/Class;)Ljava/util/Collection; iterator ()Ljava/util/Iterator; hasNext ()Z next ()Ljava/lang/Object; rdat Ljava/util/Map; java/util/Map get &(Ljava/lang/Object;)Ljava/lang/Object; java/lang/Integer parseInt (Ljava/lang/String;)I mat Res Lhaven/Material$Res; id I m Lhaven/FastMesh; animmesh "(Lhaven/FastMesh;)Lhaven/Rendered; � haven/Material$Res ()Lhaven/Material; mergemat #(Lhaven/Material;I)Lhaven/Material; #(Lhaven/Rendered;Lhaven/GLState;I)V add (Ljava/lang/Object;)Z update haven/Sprite haven/Material 
vmat.cjava ! ! "     # )  *    +  , -     . 1  2   2     *+,-� *+� � �    3       n  o  p  4 5  2   G     "*� � *� � � *� � � � � �    6    B 7 3       s  8 9  2       �� Y� M*� 	N*� 
� �  :�  � {�  � :� �  � :� � � 6� � � >� � � x~� *,� Y*� � -� � � � �  W���*-� ,�    6   $ �  : 7 ;� / < =D� � &�  3   * 
   w  x  y 3 z D { T | u } � ~ �  � � *    >  ? @  2   >     *� 	*� � *� *�  �    6     3       �  �  �  A    � &   *  $ E % 	 ' $ ( 	 / p 0	  N P 	 d � � 	code M
  haven.res.lib.vmat.Materials ����   4 � ?
  @
 A B
 A C  D
 A E F G H I
 K L
  M
  N
 	 O P Q	  R S T U
  V	  W P X P Y
  Z
  @ [
 \ ]
  ^
 _ `	  a b c empty Ljava/util/Map; 	Signature 4Ljava/util/Map<Ljava/lang/Integer;Lhaven/Material;>; mats decode Resolver InnerClasses 9(Lhaven/Resource$Resolver;Lhaven/Message;)Ljava/util/Map; Code LineNumberTable StackMapTable d e I ^(Lhaven/Resource$Resolver;Lhaven/Message;)Ljava/util/Map<Ljava/lang/Integer;Lhaven/Material;>; stdmerge 2(Lhaven/Material;Lhaven/Material;)Lhaven/Material; T S f mergemat #(Lhaven/Material;I)Lhaven/Material; <init> (Ljava/util/Map;)V 7(Ljava/util/Map<Ljava/lang/Integer;Lhaven/Material;>;)V (Lhaven/Gob;Lhaven/Message;)V <clinit> ()V 
SourceFile Materials.java haven/IntMap 7 < g h i j k l m n k e o p haven/Resource haven/Material$Res Res q r s t w t z o { d | } ~ f haven/resutil/OverTex haven/Material haven/GLState 7  $ ! � � o � 0 1 haven/Resource$Resolver � � � % ( � � �   ! haven/res/lib/vmat/Materials haven/res/lib/vmat/Mapping java/util/Map haven/Indir [Lhaven/GLState; haven/Message eom ()Z uint16 ()I getres (I)Lhaven/Indir; int8 get ()Ljava/lang/Object; java/lang/Integer valueOf (I)Ljava/lang/Integer; layer � IDLayer =(Ljava/lang/Class;Ljava/lang/Object;)Lhaven/Resource$IDLayer; � Layer )(Ljava/lang/Class;)Lhaven/Resource$Layer; ()Lhaven/Material; put 8(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object; states ([Lhaven/GLState;)V containsKey (Ljava/lang/Object;)Z &(Ljava/lang/Object;)Ljava/lang/Object; 	haven/Gob context %(Ljava/lang/Class;)Ljava/lang/Object; java/util/Collections emptyMap ()Ljava/util/Map; haven/Resource$IDLayer haven/Resource$Layer 
vmat.cjava !         !  "    #  $ !  "    #  	 % (  )   �     p� Y� M>+� � `*+� �  :+� 6� �  � 	� 
� � 	:� �  � 	� � 	:,�� 
� �  W���,�    +    � 
 ,� 9 -�  .�  *   .    &  ' 
 (  )  * # , ( - D / X 0 k 1 n 2 "    / 	 0 1  )   �     LM*� N-�66�  -2:� � � M� 	����,� +�� Y� Y+SY,S� �    +    �   2 2 3 4  �  *   & 	   6  7  8 # 9 ) : , 7 2 = 6 > 8 ?  5 6  )   V     )*� � 
�  � +�*� � 
�  � N+-� �    +     *       C  D  E # F  7 8  )   *     
*� *+� �    *       I  J 	 K "    9  7 :  )   6     *� *+� � ,� � �    *       M  N  O  ; <  )         � � �    *       "  =    � '   "    &	 	  J 	 u  v	 x  ycode �  haven.res.lib.vmat.Mapping$1 ����   4 
     <init> ()V Code LineNumberTable mergemat #(Lhaven/Material;I)Lhaven/Material; 
SourceFile Mapping.java EnclosingMethod   haven/res/lib/vmat/Mapping$1 InnerClasses haven/res/lib/vmat/Mapping 
vmat.cjava 0                     *� �              	          +�             
        
              code B  haven.res.lib.vmat.Mapping ����   4 {
  / 0
  / 2
 4 5 6 7 8 9 8 :	  ; < = > ?
 @ A	  B
 C D
  E	  F
 G H 6 I J 6 K L M
  /	  N O Q InnerClasses empty Lhaven/res/lib/vmat/Mapping; <init> ()V Code LineNumberTable mergemat #(Lhaven/Material;I)Lhaven/Material; apply #(Lhaven/Resource;)[Lhaven/Rendered; StackMapTable S T 2 ? <clinit> 
SourceFile Mapping.java    java/util/LinkedList U haven/FastMesh$MeshRes MeshRes V W X S Y Z T [ \ ] ^ _ ` vm a b c java/lang/String d e f g i j b k # $ l m n % q r s haven/Rendered t u [Lhaven/Rendered; haven/res/lib/vmat/Mapping$1   haven/res/lib/vmat/Mapping v haven/Gob$ResAttr ResAttr java/util/Collection java/util/Iterator haven/FastMesh haven/Resource layers )(Ljava/lang/Class;)Ljava/util/Collection; iterator ()Ljava/util/Iterator; hasNext ()Z next ()Ljava/lang/Object; rdat Ljava/util/Map; java/util/Map get &(Ljava/lang/Object;)Ljava/lang/Object; java/lang/Integer parseInt (Ljava/lang/String;)I mat Res Lhaven/Material$Res; haven/Material$Res ()Lhaven/Material; m Lhaven/FastMesh; haven/Material x Wrapping *(Lhaven/Rendered;)Lhaven/GLState$Wrapping; add (Ljava/lang/Object;)Z toArray (([Ljava/lang/Object;)[Ljava/lang/Object; 	haven/Gob y haven/GLState$Wrapping haven/GLState 
vmat.cjava!                 !        *� �    "        # $    % &  !        �� Y� M+� �  N-�  � v-�  � :� 	
�  � :� � � 6� #,*� � � � � �  W� "� � ,� � � � �  W���,� �  � �    '     �  ( )� - * +D� &� �  "   * 
      (  9  I  N  n  v  �  �   ,    !   #      � Y� � �    "         -    z    *         1 3 	  P R 	 C G h 	 o w p code �  haven.res.lib.vmat.Wrapping ����   4 7
  	 
 	 
  	 
 !
 " # $ %
 & '
 ( ) * + r Lhaven/Rendered; st Lhaven/GLState; mid I <init> #(Lhaven/Rendered;Lhaven/GLState;I)V Code LineNumberTable draw (Lhaven/GOut;)V setup (Lhaven/RenderList;)Z toString ()Ljava/lang/String; 
SourceFile Wrapping.java  ,       - . / #<vmat %s %s> java/lang/Object 0 1 2 3 4 5 haven/res/lib/vmat/Wrapping haven/Rendered ()V haven/RenderList add "(Lhaven/Rendered;Lhaven/GLState;)V java/lang/Integer valueOf (I)Ljava/lang/Integer; java/lang/String format 9(Ljava/lang/String;[Ljava/lang/Object;)Ljava/lang/String; 
vmat.cjava ! 
                            <     *� *+� *,� *� �           W  X 	 Y  Z  [              �           ]        *     +*� *� � �       
    `  a        3     � Y*� � SY*� S� 	�           e      6codeentry 3   gattr haven.res.lib.vmat.Materials   lib/uspr   