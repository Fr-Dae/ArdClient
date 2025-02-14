Haven Resource 1 src [  Effect.java /* Preprocessed source code */
package haven.res.lib.globfx;

import haven.*;
import haven.render.*;
import haven.render.RenderTree.Slot;
import java.util.*;
import java.lang.reflect.*;
import java.lang.ref.*;

public interface Effect extends RenderTree.Node {
    public boolean tick(float dt);
    public void gtick(Render out);
}

src   Datum.java /* Preprocessed source code */
package haven.res.lib.globfx;

import haven.*;
import haven.render.*;
import haven.render.RenderTree.Slot;
import java.util.*;
import java.lang.reflect.*;
import java.lang.ref.*;

public interface Datum {
    public boolean tick(float dt);
}

src %  GlobEffector.java /* Preprocessed source code */
package haven.res.lib.globfx;

import haven.*;
import haven.render.*;
import haven.render.RenderTree.Slot;
import java.util.*;
import java.lang.reflect.*;
import java.lang.ref.*;

public class GlobEffector extends Drawable {
    /* Keep weak references to the glob-effectors themselves, or
     * GlobEffector.glob (and GlobEffector.gob.glob) will keep the
     * globs alive through the strong value references forever. */
    static Map<Glob, Reference<GlobEffector>> cur = new WeakHashMap<Glob, Reference<GlobEffector>>();
    public final Glob glob;
    final Collection<Slot> slots = new ArrayList<>(1);
    Collection<Gob> holder = null;
    Map<Effect, Effect> effects = new HashMap<>();
    Map<Datum, Datum> data = new HashMap<>();
    Map<Slot, Map<Effect, Slot>> fxslots = new HashMap<>();
    
    private GlobEffector(Gob gob) {
	super(gob);
	this.glob = gob.glob;
    }
    
    public void added(Slot slot) {
	Collection<Pair<Effect, Slot>> added = new ArrayList<>(effects.size());
	for(Effect spr : effects.values()) {
	    added.add(new Pair<>(spr, slot.add(spr)));
	}
	slots.add(slot);
	for(Pair<Effect, Slot> fs : added)
	    fxslots.computeIfAbsent(slot, k -> new HashMap<>()).put(fs.a, fs.b);
    }

    public void removed(Slot slot) {
	slots.remove(slot);
	fxslots.remove(slot);
    }
    
    public void ctick(double ddt) {
	float dt = (float)ddt;
	for(Iterator<Effect> i = effects.values().iterator(); i.hasNext();) {
	    Effect spr = i.next();
	    if(spr.tick(dt)) {
		i.remove();
		for(Map<Effect, Slot> ms : fxslots.values()) {
		    Slot slot = ms.remove(spr);
		    if(slot == null)
			System.err.printf("warning: globfx effect-slot not present when auto-removing %s\n", spr);
		    else
			slot.remove();
		}
	    }
	}
	for(Iterator<Datum> i = data.values().iterator(); i.hasNext();) {
	    Datum d = i.next();
	    if(d.tick(dt))
		i.remove();
	}
	synchronized(cur) {
	    if((effects.size() == 0) && (data.size() == 0)) {
		glob.oc.lrem(holder);
		cur.remove(glob);
	    }
	}
    }

    public void gtick(Render out) {
	for(Effect spr : effects.values())
	    spr.gtick(out);
    }
    
    public Resource getres() {
	return(null);
    }
    
    private <T> T create(Class<T> fx) {
	Resource res = Resource.classres(fx);
	try {
	    try {
		Constructor<T> cons = fx.getConstructor(Sprite.Owner.class, Resource.class);
		return(cons.newInstance(gob, res));
	    } catch(NoSuchMethodException e) {}
	    throw(new RuntimeException("No valid constructor found for global effect " + fx));
	} catch(InstantiationException e) {
	    throw(new RuntimeException(e));
	} catch(IllegalAccessException e) {
	    throw(new RuntimeException(e));
	} catch(InvocationTargetException e) {
	    if(e.getCause() instanceof RuntimeException)
		throw((RuntimeException)e.getCause());
	    throw(new RuntimeException(e));
	}
    }

    public Object monitor() {
	return(this.gob);
    }

    @SuppressWarnings("unchecked")
    public <T extends Effect> T get(T fx) {
	synchronized(this.gob) {
	    T ret = (T)effects.get(fx);
	    if(ret == null) {
		Collection<Pair<Slot, Slot>> added = new ArrayList<>(slots.size());
		try {
		    for(Slot slot : slots)
			added.add(new Pair(slot, slot.add(fx)));
		} catch(RuntimeException e) {
		    for(Pair<Slot, Slot> slotm : added)
			slotm.b.remove();
		    throw(e);
		}
		effects.put(ret = fx, fx);
		for(Pair<Slot, Slot> slotm : added)
		    fxslots.computeIfAbsent(slotm.a, k -> new HashMap<>()).put(fx, slotm.b);
	    }
	    return(ret);
	}
    }
    
    @SuppressWarnings("unchecked")
    public <T extends Datum> T getdata(T fx) {
	synchronized(this.gob) {
	    T ret = (T)data.get(fx);
	    if(ret == null)
		data.put(ret = fx, fx);
	    return(ret);
	}
    }
    
    public static GlobEffector get(Glob glob) {
	Collection<Gob> add = null;
	GlobEffector ret;
	synchronized(cur) {
	    Reference<GlobEffector> ref = cur.get(glob);
	    ret = (ref == null) ? null : ref.get();
	    if(ret == null) {
		Gob hgob = new Gob(glob, Coord2d.z) {
			public Coord3f getc() {
			    return(Coord3f.o);
			}

			public Pipe.Op getmapstate(Coord3f pc) {
			    return(null);
			}
		    };
		GlobEffector ne = new GlobEffector(hgob);
		hgob.setattr(ne);
		add = ne.holder = Collections.singleton(hgob);
		cur.put(glob, new WeakReference<GlobEffector>(ret = ne));
	    }
	}
	if(add != null)
	    glob.oc.ladd(add);
	return(ret);
    }

    public static <T extends Effect> T get(Glob glob, T fx) {
	return(get(glob).get(fx));
    }

    public static <T extends Datum> T getdata(Glob glob, T fx) {
	return(get(glob).getdata(fx));
    }
}

src �  GlobEffect.java /* Preprocessed source code */
package haven.res.lib.globfx;

import haven.*;
import haven.render.*;
import haven.render.RenderTree.Slot;
import java.util.*;
import java.lang.reflect.*;
import java.lang.ref.*;

public abstract class GlobEffect implements Effect {
    public int hashCode() {
	return(this.getClass().hashCode());
    }

    public boolean equals(Object o) {
	return(this.getClass() == o.getClass());
    }
}

src �  GlobData.java /* Preprocessed source code */
package haven.res.lib.globfx;

import haven.*;
import haven.render.*;
import haven.render.RenderTree.Slot;
import java.util.*;
import java.lang.reflect.*;
import java.lang.ref.*;

public abstract class GlobData implements Datum {
    public int hashCode() {
	return(this.getClass().hashCode());
    }

    public boolean equals(Object o) {
	return(this.getClass() == o.getClass());
    }
}
code E  haven.res.lib.globfx.Effect ����   4  
   tick (F)Z gtick (Lhaven/render/Render;)V 
SourceFile Effect.java haven/res/lib/globfx/Effect java/lang/Object  haven/render/RenderTree$Node Node InnerClasses haven/render/RenderTree globfx.cjava                         
    	code �   haven.res.lib.globfx.Datum ����   4 
   tick (F)Z 
SourceFile 
Datum.java haven/res/lib/globfx/Datum java/lang/Object globfx.cjava                 	code �  haven.res.lib.globfx.GlobEffector$1 ����   4 $
  	     <init> (Lhaven/Glob;Lhaven/Coord2d;)V Code LineNumberTable getc ()Lhaven/Coord3f; getmapstate  Op InnerClasses '(Lhaven/Coord3f;)Lhaven/render/Pipe$Op; 
SourceFile GlobEffector.java EnclosingMethod         ! #haven/res/lib/globfx/GlobEffector$1 	haven/Gob " haven/render/Pipe$Op !haven/res/lib/globfx/GlobEffector get 1(Lhaven/Glob;)Lhaven/res/lib/globfx/GlobEffector; haven/Coord3f o Lhaven/Coord3f; haven/render/Pipe globfx.cjava 0                     *+,� �           �  	 
          � �           �             �           �      #        	            code R  haven.res.lib.globfx.GlobEffector ����   4_
 V � �
  �	 G �	 G � �
  �	 G �	 G �	 G �	 � �	 G �  �  � � � � � � � � � ! �
  � � �   �  � �	  �	  �  � � �  �  � � � �	 � � � �
 � � ! � � ' �	 G �	 � �
 � �  �
 0 � � � �
 . �	 G �
 � � � � �
 6 � �
 6 �
 6 �
 6 �
 5 � �
 5 � � �
 @ �  � � �  � �
 E � � �	 � �
 H �
 G �
 � �
 � � �
 N �
 � �
 G �
 G �
 G � 
 T � InnerClasses cur Ljava/util/Map; 	Signature [Ljava/util/Map<Lhaven/Glob;Ljava/lang/ref/Reference<Lhaven/res/lib/globfx/GlobEffector;>;>; glob Lhaven/Glob; slots Ljava/util/Collection; Slot 6Ljava/util/Collection<Lhaven/render/RenderTree$Slot;>; holder #Ljava/util/Collection<Lhaven/Gob;>; effects KLjava/util/Map<Lhaven/res/lib/globfx/Effect;Lhaven/res/lib/globfx/Effect;>; data ILjava/util/Map<Lhaven/res/lib/globfx/Datum;Lhaven/res/lib/globfx/Datum;>; fxslots {Ljava/util/Map<Lhaven/render/RenderTree$Slot;Ljava/util/Map<Lhaven/res/lib/globfx/Effect;Lhaven/render/RenderTree$Slot;>;>; <init> (Lhaven/Gob;)V Code LineNumberTable added !(Lhaven/render/RenderTree$Slot;)V StackMapTable removed ctick (D)V � � � � gtick (Lhaven/render/Render;)V getres ()Lhaven/Resource; create %(Ljava/lang/Class;)Ljava/lang/Object; � � � � � � � 1<T:Ljava/lang/Object;>(Ljava/lang/Class<TT;>;)TT; monitor ()Ljava/lang/Object; get <(Lhaven/res/lib/globfx/Effect;)Lhaven/res/lib/globfx/Effect; � *<T::Lhaven/res/lib/globfx/Effect;>(TT;)TT; getdata :(Lhaven/res/lib/globfx/Datum;)Lhaven/res/lib/globfx/Datum; � )<T::Lhaven/res/lib/globfx/Datum;>(TT;)TT; 1(Lhaven/Glob;)Lhaven/res/lib/globfx/GlobEffector; � H(Lhaven/Glob;Lhaven/res/lib/globfx/Effect;)Lhaven/res/lib/globfx/Effect; 6<T::Lhaven/res/lib/globfx/Effect;>(Lhaven/Glob;TT;)TT; F(Lhaven/Glob;Lhaven/res/lib/globfx/Datum;)Lhaven/res/lib/globfx/Datum; 5<T::Lhaven/res/lib/globfx/Datum;>(Lhaven/Glob;TT;)TT; lambda$get$1 /(Lhaven/render/RenderTree$Slot;)Ljava/util/Map; lambda$added$0 <clinit> ()V 
SourceFile GlobEffector.java j k java/util/ArrayList j ^ _ b _ java/util/HashMap j � d Y f Y h Y \ ]	
 � haven/res/lib/globfx/Effect 
haven/Pair j BootstrapMethods � java/util/Map !"##$%# �& haven/render/RenderTree$Slot'() >warning: globfx effect-slot not present when auto-removing %s
 java/lang/Object*+, haven/res/lib/globfx/Datum X Y-./01 { |23 java/lang/Class4 haven/Sprite$Owner Owner haven/Resource56789:; java/lang/NoSuchMethodException java/lang/RuntimeException java/lang/StringBuilder -No valid constructor found for global effect <=<>?@ jA  java/lang/InstantiationException jB  java/lang/IllegalAccessException +java/lang/reflect/InvocationTargetExceptionCD �E java/lang/ref/Reference � � !haven/res/lib/globfx/GlobEffector #haven/res/lib/globfx/GlobEffector$1FGH jIJKLMN java/lang/ref/WeakReference jOP1 � � � � � � java/util/WeakHashMap haven/Drawable java/util/Collection java/util/Iterator java/lang/Throwable 
haven/Glob (I)V 	haven/Gob size ()I values ()Ljava/util/Collection; iterator ()Ljava/util/Iterator; hasNext ()Z next addQ Node >(Lhaven/render/RenderTree$Node;)Lhaven/render/RenderTree$Slot; '(Ljava/lang/Object;Ljava/lang/Object;)V (Ljava/lang/Object;)Z
RS &(Ljava/lang/Object;)Ljava/lang/Object;
 GT apply ()Ljava/util/function/Function; computeIfAbsent C(Ljava/lang/Object;Ljava/util/function/Function;)Ljava/lang/Object; a Ljava/lang/Object; b put 8(Ljava/lang/Object;Ljava/lang/Object;)Ljava/lang/Object; remove tick (F)Z haven/render/RenderTree java/lang/System err Ljava/io/PrintStream; java/io/PrintStream printf <(Ljava/lang/String;[Ljava/lang/Object;)Ljava/io/PrintStream; oc Lhaven/OCache; haven/OCache lrem (Ljava/util/Collection;)V classres #(Ljava/lang/Class;)Lhaven/Resource; haven/Sprite getConstructor 3([Ljava/lang/Class;)Ljava/lang/reflect/Constructor; gob Lhaven/Gob; java/lang/reflect/Constructor newInstance '([Ljava/lang/Object;)Ljava/lang/Object; append -(Ljava/lang/String;)Ljava/lang/StringBuilder; -(Ljava/lang/Object;)Ljava/lang/StringBuilder; toString ()Ljava/lang/String; (Ljava/lang/String;)V (Ljava/lang/Throwable;)V getCause ()Ljava/lang/Throwable;
 GU haven/Coord2d z Lhaven/Coord2d; (Lhaven/Glob;Lhaven/Coord2d;)V setattr (Lhaven/GAttrib;)V java/util/Collections 	singleton #(Ljava/lang/Object;)Ljava/util/Set; (Ljava/lang/Object;)V ladd haven/render/RenderTree$NodeVWZ � � � � "java/lang/invoke/LambdaMetafactory metafactory\ Lookup �(Ljava/lang/invoke/MethodHandles$Lookup;Ljava/lang/String;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodType;Ljava/lang/invoke/MethodHandle;Ljava/lang/invoke/MethodType;)Ljava/lang/invoke/CallSite;] %java/lang/invoke/MethodHandles$Lookup java/lang/invoke/MethodHandles globfx.cjava ! G V     X Y  Z    [  \ ]    ^ _  Z    a   b _  Z    c   d Y  Z    e   f Y  Z    g   h Y  Z    i   j k  l   t     @*+� *� Y� � *� *� Y� � *� Y� � 	*� Y� � 
*+� � �    m   "            !  ,  7 ! ? "  n o  l   �     �� Y*� �  � M*� �  �  N-�  � )-�  � :,� Y+�  � �  W���*� +�  W,�  N-�  � 3-�  � :*� 
+�   �  � � � �  W��ʱ    p    �   q r� .�  r� 8 m   "    %  & 4 ' L ( O ) Z * u + � ,  s o  l   7     *� +�  W*� 
+�  W�    m       /  0  1  t u  l  �  
  '�F*� �  �  :�  � |�  � :%�  � b�   *� 
�  �  :�  � A�  � :�  � !:� � "#� $YS� %W� 
� & ������*� 	�  �  :�  � $�  � ':%� ( � 
�   ��ز )Y:�*� �  � **� 	�  � *� � **� � +� )*� �  Wç :	�	��  �      p   ; �  r� 7 v r� = w x� � � �  r'� � 9 yE z�  m   ^    4  5  6 ) 7 4 8 ; 9 a : o ; t < � > � ? � A � B � C � D � E � F � G � H � I � J L M  { |  l   ^     -*� �  �  M,�  � ,�  � N-+� , ���    p    �  r�  m       P " Q , R  } ~  l        �    m       U   �  l  %     x+� -M+� .Y/SY0S� 1N-� $Y*� 2SY,S� 3�N� 5Y� 6Y� 78� 9+� :� ;� <�N� 5Y-� >�N� 5Y-� >�N-� A� 5� -� A� 5�� 5Y-� >�   + , 4  + H = , H H =  + R ? , H R ?  + \ @ , H \ @  p   ' � ,  � � �  �[ �I �I ��  � m   6    Y  \  ] , ^ - _ H ` I a R b S c \ d ] e g f o g Z    �  � �  l        *� 2�    m       l  � �  l  �  	   �*� 2YM�*� +� B � N-� ۻ Y*� � C � :*� �  :�  � +�  � !:� Y+�  � �  W��ѧ 7:�  :�  � �  � :� � !� & ����*� +YN+�  W�  :�  � 4�  � :*� 
� � D  �  � +� �  W���-,ð:,��  + h k 5  � �   � � �    p   M 	� 6  � v y v q r  � 1B �� 
 � r� %� �  r� :�   � v y  z m   B    q  r  s  t + v L w h | k x m y � z � { � } � ~ �  � � � � Z    �  � �  l   �     2*� 2YM�*� 	+� B � 'N-� *� 	+YN+�  W-,ð:,��   * +   + / +    p    � ' y ��   � � y  z m       �  �  �  � ' � + � Z    � 	 � �  l  :     �L� )YN² )*� B � E:� � � F� GM,� C� HY*� I� J:� GY� K:� L� MZ� L� )*� NYYM� O�  W-ç 
:-��+� *� *+� P,�   n q   q u q    p   R �   � q  y �  G �� D  � q � y  �   � q  y  z�   � q �   m   :    �  �  �  � ( � , � 9 � D � K � W � l � x � | � � � 	 � �  l   !     	*� Q+� R�    m       � Z    � 	 � �  l   !     	*� Q+� S�    m       � Z    �
 � �  l         � Y� �    m       
 � �  l         � Y� �    m       +  � �  l   #      � TY� U� )�    m         �     �  � � � �  � � � �   ^ W   *  H      ! � `	 / � �	 �	X[Y code   haven.res.lib.globfx.GlobEffect ����   4 
  
  
      <init> ()V Code LineNumberTable hashCode ()I equals (Ljava/lang/Object;)Z StackMapTable 
SourceFile GlobEffect.java       haven/res/lib/globfx/GlobEffect java/lang/Object haven/res/lib/globfx/Effect getClass ()Ljava/lang/Class; globfx.cjava!            	        *� �    
       �     	         *� � �    
       �     	   4     *� +� � � �        @ 
       �      code 	  haven.res.lib.globfx.GlobData ����   4 
  
  
      <init> ()V Code LineNumberTable hashCode ()I equals (Ljava/lang/Object;)Z StackMapTable 
SourceFile GlobData.java       haven/res/lib/globfx/GlobData java/lang/Object haven/res/lib/globfx/Datum getClass ()Ljava/lang/Class; globfx.cjava!            	        *� �    
       �     	         *� � �    
       �     	   4     *� +� � � �        @ 
       �      codeentry     