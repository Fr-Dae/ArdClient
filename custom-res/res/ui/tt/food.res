Haven Resource 1 src �  Fac.java /* Preprocessed source code */
import haven.*;
import java.awt.Color;
import java.util.*;
import java.awt.image.*;
import static haven.resutil.FoodInfo.Effect;
import static haven.resutil.FoodInfo.Event;

/* >tt: Fac */
public class Fac implements ItemInfo.InfoFactory {
    public ItemInfo build(ItemInfo.Owner owner, ItemInfo.Raw raw, Object... args) {
	int c = 1;
	double end = ((Number)args[c++]).doubleValue();
	double glut = ((Number)args[c++]).doubleValue();
	double cons = 0;
	if(args[c] instanceof Number)
	    cons = ((Number)args[c++]).doubleValue();
	Object[] evd = (Object[])args[c++];
	Object[] efd = (Object[])args[c++];
	Object[] tpd = (Object[])args[c++];

	Collection<Event> evs = new LinkedList<Event>();
	Collection<Effect> efs = new LinkedList<Effect>();
	Resource.Resolver rr = owner.context(Resource.Resolver.class);
	for(int a = 0; a < evd.length; a += 2)
	    evs.add(new Event(rr.getres((Integer)evd[a]).get(),
			      ((Number)evd[a + 1]).doubleValue()));
	for(int a = 0; a < efd.length; a += 2)
	    efs.add(new Effect(ItemInfo.buildinfo(owner, new Object[] {(Object[])efd[a]}),
			       ((Number)efd[a + 1]).doubleValue()));

	int[] types;
	{
	    int[] buf = new int[tpd.length * 32];
	    int n = 0, t = 0;
	    for(int i = 0; i < tpd.length; i++) {
		for(int b = 0, m = 1; b < 32; b++, m <<= 1, t++) {
		    if(((Integer)tpd[i] & m) != 0)
			buf[n++] = t;
		}
	    }
	    types = new int[n];
	    for(int i = 0; i < n; i++)
		types[i] = buf[i];
	}

	try {
	    return(new haven.resutil.FoodInfo(owner, end, glut, cons, evs.toArray(new Event[0]), efs.toArray(new Effect[0]), types));
	} catch(NoSuchMethodError e) {
	    return(new haven.resutil.FoodInfo(owner, end, glut, evs.toArray(new Event[0]), efs.toArray(new Effect[0]), types));
	}
    }
}
code �	  Fac ����   4 q
  3 4
  5 6 7
  3 8 # : ; =
 
 >  ? @ A B
 	 C D E F H
 I J
  K L D M N O
  P Q
  R S T <init> ()V Code LineNumberTable build V Owner InnerClasses W Raw O(Lhaven/ItemInfo$Owner;Lhaven/ItemInfo$Raw;[Ljava/lang/Object;)Lhaven/ItemInfo; StackMapTable S V W X 8 Y Q 
SourceFile Fac.java   java/lang/Number Z [ [Ljava/lang/Object; java/util/LinkedList haven/Resource$Resolver Resolver \ ] haven/resutil/FoodInfo$Event Event java/lang/Integer ^ _ ` a b c d haven/Resource  e X f g haven/resutil/FoodInfo$Effect Effect java/lang/Object h i j  k haven/resutil/FoodInfo l m [Lhaven/resutil/FoodInfo$Event;  [Lhaven/resutil/FoodInfo$Effect;  n java/lang/NoSuchMethodError  o Fac haven/ItemInfo$InfoFactory InfoFactory haven/ItemInfo$Owner haven/ItemInfo$Raw java/util/Collection [I doubleValue ()D context %(Ljava/lang/Class;)Ljava/lang/Object; intValue ()I getres (I)Lhaven/Indir; haven/Indir get ()Ljava/lang/Object; (Lhaven/Resource;D)V add (Ljava/lang/Object;)Z haven/ItemInfo 	buildinfo ;(Lhaven/ItemInfo$Owner;[Ljava/lang/Object;)Ljava/util/List; (Ljava/util/List;D)V toArray (([Ljava/lang/Object;)[Ljava/lang/Object; ](Lhaven/ItemInfo$Owner;DDD[Lhaven/resutil/FoodInfo$Event;[Lhaven/resutil/FoodInfo$Effect;[I)V \(Lhaven/ItemInfo$Owner;DD[Lhaven/resutil/FoodInfo$Event;[Lhaven/resutil/FoodInfo$Effect;[I)V 
food.cjava !                     *� �    !       	 � " (     �    �6-�2� � 9-�2� � 99	-2� � -�2� � 9	-�2� � :-�2� � :-�2� � :� Y� :� Y� :+�  � :6�� ?� 	Y2� 
� �  �  � `2� � � �  W����6�� ;� Y+� Y2� � S� `2� � � �  W����� h�
:666�� @66 � -2� 
� ~� �O�x6���҄����
:6� .O���� Y+	� 	�  � � �  � � �:� Y+� 	�  � � �  � � � ���   )   � � =  * + ,   � N  * + ,     - - .  � C� � ?�   * + ,     - - .  /  � !� � �   * + ,     - - . / /  �   * + ,     - - . /  l 0 !   � %        !  $  .  =  L  [  j  s  |  �  �  �  �  �  �  �     ! "# #. $; %L &V $e #k )q *{ +� *� /� 0� 1  1    p %   2  # I $	 & I ' 	   9	 	  < 	   G 	  I U	codeentry 
   tt Fac   