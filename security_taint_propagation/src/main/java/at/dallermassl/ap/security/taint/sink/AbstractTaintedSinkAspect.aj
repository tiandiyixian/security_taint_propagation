/**
 * 
 */
package at.dallermassl.ap.security.taint.sink;

import java.util.Set;

import org.aspectj.lang.JoinPoint;

import at.dallermassl.ap.security.taint.source.TaintedSourceInfo;

/**
 * Defines the behavior when a tainted content is passed to an armoured sink.
 * 
 * @author cdaller
 */
public abstract aspect AbstractTaintedSinkAspect {

    private static boolean blockTainted = false;

    /**
     * Returns <code>true</code> if a sink should throw an exception when received tainted content.
     * @return <code>true</code> if a sink should throw an exception when received tainted content.
     */
    public static boolean isBlockTainted() {
        return blockTainted;
    }
    
    /**
     * If set to <code>true</code> an exception is thrown if a tainted string is passed to a sink. 
     * @param blockTainted if set to <code>true</code> an exception is thrown if a tainted string is 
     * passed to a sink.
     */
    public static void setBlockTainted(boolean blockTainted) {
        AbstractTaintedSinkAspect.blockTainted = blockTainted;
    }

    
    /**
     * Method called if a tainted value should be used.
     * @param value the value to be used.
     */
    public void handleTaintedSink(JoinPoint joinPoint, String value) {
        value.setTainted(false);        
        int[] sourceIds = value.getTaintedSourceIds();
        StringBuilder sourceIdInfos = new StringBuilder();
        String prefix = "";
        for (int sourceId : sourceIds) {
            sourceIdInfos.append(prefix);
            sourceIdInfos.append(TaintedSourceInfo.getSourceInfo(sourceId));
            prefix = ", ";
        }
        StringBuilder messageBuilder = new StringBuilder("SECURITY-TAINT-WARNING: Tainted value will be used in a sink!");
        messageBuilder.append("[");
        messageBuilder.append(" source code: ");
        messageBuilder.append(joinPoint.getSourceLocation());
        messageBuilder.append(",");
        messageBuilder.append(" sink code: ");
        messageBuilder.append(joinPoint.toShortString());
        messageBuilder.append(",");
        messageBuilder.append( "tainted sources: ");
        messageBuilder.append(sourceIdInfos);
        messageBuilder.append(",");
        messageBuilder.append(" value: '");
        messageBuilder.append(value);
        messageBuilder.append("'");
        messageBuilder.append("]");
        if (isBlockTainted()) {
            value.setTainted(true);        
            throw new SecurityException(messageBuilder.toString());
        } else {
            System.err.println(messageBuilder.toString());
        }
        value.setTainted(true);        
    }

}
